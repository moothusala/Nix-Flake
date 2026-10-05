{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.alacritty = {
    home-manager.users.${username}.imports = [ hm.alacritty ];
  };

  flake.modules.homeManager.alacritty = {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal.family = "JetBrainsMono Nerd Font";
          size = 11;
        };
        window.padding = {
          x = 6;
          y = 6;
        };
      };
    };
  };
}
