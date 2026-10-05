{
  flake.modules.nixos.networking =
    { lib, ... }:
    {
      networking.networkmanager.enable = lib.mkDefault true;
      networking.firewall.enable = true;

      # Resolve/advertise <hostname>.local so machines are reachable by name.
      services.avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };
    };
}
