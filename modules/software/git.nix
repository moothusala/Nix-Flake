{ config, ... }:
let
  inherit (config.meta) username fullName email;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.git = {
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
    home-manager.users.${username}.imports = [ hm.git ];
  };

  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = fullName;
          inherit email;
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
  };
}
