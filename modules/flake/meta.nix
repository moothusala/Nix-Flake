# Flake-wide facts shared by every module (the primary user, keys, identity).
# Read them from any flake-parts module via `config.meta.<name>`.
{ lib, ... }:
{
  options.meta = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };

  config.meta = {
    username = "moothusala";
    fullName = "moothusala";
    email = "gleurquin@gmail.com";

    sshAuthorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQnOnsjywU7d2Dd2QNXoKhg8z0ZgD35kx4S9/3RShAX gleurquin@gmail.com"
    ];

    timeZone = "America/Chicago";
    locale = "en_US.UTF-8";
  };
}
