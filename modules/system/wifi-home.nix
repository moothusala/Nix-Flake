# Home Wi-Fi networks, pre-configured in NetworkManager.
# Passphrases come from the `wifi-env` sops secret, an env file:
#   WASABI_PSK=...
#   WASABI_FAST_PSK=...
{
  flake.modules.nixos.wifi-home =
    { config, ... }:
    let
      wpa2 = id: pskVar: priority: {
        connection = {
          inherit id;
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = priority;
        };
        wifi = {
          ssid = id;
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$" + pskVar;
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    in
    {
      sops.secrets.wifi-env = { };

      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ config.sops.secrets.wifi-env.path ];
        profiles = {
          # Prefer the fast network when both are in range.
          Wasabi_Fast = wpa2 "Wasabi_Fast" "WASABI_FAST_PSK" 20;
          Wasabi = wpa2 "Wasabi" "WASABI_PSK" 10;
        };
      };
    };
}
