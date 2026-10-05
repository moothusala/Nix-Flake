{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.lazygit = {
    home-manager.users.${username}.imports = [ hm.lazygit ];
  };

  flake.modules.homeManager.lazygit = {
    programs.lazygit = {
      enable = true;
      settings.gui.nerdFontsVersion = "3";
    };
  };
}
