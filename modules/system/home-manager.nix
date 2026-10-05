# Home Manager as a NixOS module. Software modules that need per-user
# dotfiles add their `homeManager.<name>` half to the primary user.
{ inputs, config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.home-manager =
    { config, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        users.${username} = {
          home.stateVersion = config.system.stateVersion;
        };
      };
    };
}
