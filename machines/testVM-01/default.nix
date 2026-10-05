# testVM-01: Hyper-V guest, desktop + development.
# This file is the host's module list; hardware.nix and configuration.nix
# add to the `host-testVM-01` module.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.testVM-01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      profile-base
      profile-desktop
      profile-development
      smb-automount
      niri-software-render # Hyper-V has no GPU
      host-testVM-01
    ];
  };
}
