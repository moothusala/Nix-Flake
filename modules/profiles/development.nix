# Developer tooling. Works on desktops and headless hosts (vscode needs a desktop).
{ config, ... }:
{
  flake.modules.nixos.profile-development = {
    imports = with config.flake.modules.nixos; [
      lazyvim
      lazygit
      vscode
      dotnet
      python
      containers
    ];
  };
}
