# Noctalia shell (bar, launcher, notifications), started as a systemd user
# service with the graphical session; niri-session pulls that target in.
{ inputs, ... }:
{
  flake.modules.nixos.noctalia = {
    imports = [ inputs.noctalia.nixosModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      recommendedServices.enable = true;
    };
  };
}
