{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.fzf =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.fd ];
      home-manager.users.${username}.imports = [ hm.fzf ];
    };

  flake.modules.homeManager.fzf = {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidget.command = "fd --type f --hidden --exclude .git";
      changeDirWidget.command = "fd --type d --hidden --exclude .git";
    };
  };
}
