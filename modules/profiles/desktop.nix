# Graphical workstation: Wayland + mango + Noctalia, audio, GUI apps, YubiKey.
{ config, ... }:
{
  flake.modules.nixos.profile-desktop = {
    imports = with config.flake.modules.nixos; [
      wayland
      mango
      noctalia
      pipewire
      alacritty
      vscode
      brave
      yubikey
    ];
  };
}
