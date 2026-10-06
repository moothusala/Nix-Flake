# Oberon: Lenovo ThinkPad T460s, full desktop + development.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.Oberon = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      profile-base
      profile-desktop
      profile-development
      profile-laptop
      smb-automount
      disk-labels
      host-Oberon
    ];
  };
}
