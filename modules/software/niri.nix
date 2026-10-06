# niri compositor + greetd/tuigreet login. Pair with `wayland` and `noctalia`.
# The user's niri config is ./_niri/config.kdl (scrolling layout, touchpad
# scrolling, Noctalia keybinds).
{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
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
        alacritty # Mod+T
      ];

      home-manager.users.${username}.imports = [ hm.niri ];
    };

  flake.modules.homeManager.niri = {
    xdg.configFile."niri/config.kdl".source = ./_niri/config.kdl;
  };
}
