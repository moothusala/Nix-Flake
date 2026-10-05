# The primary user: same password (from sops) and SSH key on every host,
# member of wheel, passwordless sudo. Requires the `sops` module.
{ config, ... }:
let
  inherit (config.meta) username fullName sshAuthorizedKeys;
in
{
  flake.modules.nixos.users =
    { config, ... }:
    {
      # Users are fully declarative; passwords can't drift between hosts.
      users.mutableUsers = false;

      sops.secrets."users/${username}/hashedPassword".neededForUsers = true;

      users.users.${username} = {
        isNormalUser = true;
        description = fullName;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."users/${username}/hashedPassword".path;
        openssh.authorizedKeys.keys = sshAuthorizedKeys;
      };

      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };
}
