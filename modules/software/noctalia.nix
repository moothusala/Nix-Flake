# Noctalia shell (bar, launcher, notifications), started as a systemd user
# service with the graphical session; mango-session.target pulls that in.
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
