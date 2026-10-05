# LazyVim for the primary user, fully declarative via lazyvim-nix
# (plugins pinned by the flake, Mason disabled; tools come from Nix).
{ inputs, config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.lazyvim = {
    home-manager.users.${username}.imports = [ hm.lazyvim ];
  };

  flake.modules.homeManager.lazyvim =
    { pkgs, ... }:
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      programs.lazyvim = {
        enable = true;
        extras = {
          lang.nix.enable = true;
          lang.python.enable = true;
          lang.json.enable = true;
          lang.markdown.enable = true;
        };
        extraPackages = with pkgs; [
          nixd
          nixfmt
        ];
      };
    };
}
