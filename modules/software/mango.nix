# mango (mangowm) compositor + greetd/tuigreet login. Pair with `wayland`
# and `noctalia`. The user's mango config is ./_mango/config.conf
# (scroller layout, touchpad scrolling, Noctalia keybinds).
{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.mango =
    { pkgs, ... }:
    {
      programs.mango.enable = true;

      # mango runs `systemctl --user start mango-session.target` on startup,
      # which brings up graphical-session.target (and with it Noctalia and
      # the portals). The package ships this unit under share/, which NixOS
      # doesn't pick up, so declare it here.
      systemd.user.targets.mango-session = {
        description = "mango compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd mango";
          user = "greeter";
        };
      };

      environment.systemPackages = [ pkgs.alacritty ]; # SUPER+T

      home-manager.users.${username}.imports = [ hm.mango ];
    };

  flake.modules.homeManager.mango = {
    xdg.configFile."mango/config.conf".source = ./_mango/config.conf;
  };
}
