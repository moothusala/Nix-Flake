# niri compositor + greetd/tuigreet login. Pair with `wayland` and `noctalia`.
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri.enable = true;

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd niri-session";
          user = "greeter";
        };
      };

      environment.systemPackages = with pkgs; [
        xwayland-satellite # X11 apps under niri
        fuzzel # default launcher in niri's stock config (Mod+D)
        alacritty # default terminal in niri's stock config (Mod+T)
      ];
    };
}
