# Common Wayland desktop plumbing, independent of the compositor.
{
  flake.modules.nixos.wayland =
    { pkgs, ... }:
    {
      hardware.graphics.enable = true;

      # Electron/Chromium apps (VS Code) run natively on Wayland.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;

      environment.systemPackages = with pkgs; [
        wl-clipboard
        xdg-utils
      ];

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];
    };
}
