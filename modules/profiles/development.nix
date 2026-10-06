# Command-line developer tooling. Safe for headless hosts.
{ config, ... }:
{
  flake.modules.nixos.profile-development = {
    imports = with config.flake.modules.nixos; [
      lazyvim
      lazygit
      dotnet
      python
      containers
    ];
  };
}
