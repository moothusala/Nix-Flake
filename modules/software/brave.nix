# Brave browser. Runs natively on Wayland via NIXOS_OZONE_WL (set in `wayland`).
{
  flake.modules.nixos.brave =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.brave ];
    };
}
