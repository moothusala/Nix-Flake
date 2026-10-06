# Generic laptop support. Power profiles come from power-profiles-daemon
# (enabled by `noctalia`), which nixos-hardware's TLP default yields to.
{
  flake.modules.nixos.laptop =
    { lib, ... }:
    {
      # Wi-Fi/Bluetooth firmware (Intel iwlwifi etc.).
      hardware.enableRedistributableFirmware = true;
      hardware.bluetooth.enable = lib.mkDefault true;

      services.upower.enable = true;
      services.thermald.enable = lib.mkDefault true;
      services.fwupd.enable = true;
      services.libinput.enable = true;

      # Close the lid to suspend; Noctalia locks the session first.
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };

      zramSwap.enable = true;
    };
}
