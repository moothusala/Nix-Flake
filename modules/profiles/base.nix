# Everything every host (desktop or server) gets. Include exactly once per host.
{ config, ... }:
{
  flake.modules.nixos.profile-base = {
    imports = with config.flake.modules.nixos; [
      nix-settings
      boot-efi
      locale
      networking
      sops
      users
      home-manager
      openssh
      zsh
      git
      fzf
      nvim
    ];
  };
}
