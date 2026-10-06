# Laptop hardware: power management, firmware, home Wi-Fi.
{ config, ... }:
{
  flake.modules.nixos.profile-laptop = {
    imports = with config.flake.modules.nixos; [
      laptop
      wifi-home
    ];
  };
}
