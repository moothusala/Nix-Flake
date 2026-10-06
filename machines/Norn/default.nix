# Norn: Panasonic Let's Note CF-SV7, full desktop + development.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.Norn = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      profile-base
      profile-desktop
      profile-development
      profile-laptop
      smb-automount
      disk-labels
      host-Norn
    ];
  };
}
