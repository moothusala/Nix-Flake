{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.zsh =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.users.${username}.shell = pkgs.zsh;
      # Lets zsh find completions for system packages (needed with Home Manager).
      environment.pathsToLink = [ "/share/zsh" ];

      home-manager.users.${username}.imports = [ hm.zsh ];
    };

  flake.modules.homeManager.zsh = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        share = true;
      };
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "sudo"
        ];
      };
    };
  };
}
