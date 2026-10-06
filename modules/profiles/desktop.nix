# Graphical workstation: Wayland + niri + Noctalia, audio, GUI apps, YubiKey.
{ config, ... }:
{
  flake.modules.nixos.profile-desktop = {
    imports = with config.flake.modules.nixos; [
      wayland
      niri
      noctalia
      pipewire
      alacritty
      vscode
      yubikey
    ];
  };
}
