# testVM-01: Hyper-V guest, headless (SSH only) + command-line development.
# This file is the host's module list; hardware.nix and configuration.nix
# add to the `host-testVM-01` module.
{ inputs, config, ... }:
{
  flake.nixosConfigurations.testVM-01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with config.flake.modules.nixos; [
      profile-base
      profile-development
      smb-automount
      host-testVM-01
    ];
  };
}
