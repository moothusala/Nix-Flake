{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.nix-settings = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        username
      ];
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # vscode and a few others are unfree.
    nixpkgs.config.allowUnfree = true;
  };
}
