# Graphical workstation: Wayland + niri + Noctalia, audio, terminal, YubiKey.
{ config, ... }:
{
  flake.modules.nixos.profile-desktop = {
    imports = with config.flake.modules.nixos; [
      wayland
      niri
      noctalia
      pipewire
      alacritty
      yubikey
    ];
  };
}
