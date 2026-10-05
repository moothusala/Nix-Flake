# System-wide Neovim as the default editor (also used by root / sudoedit).
# The primary user's LazyVim setup lives in `lazyvim`.
{
  flake.modules.nixos.nvim =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      environment.systemPackages = with pkgs; [
        ripgrep
        fd
      ];
    };
}
