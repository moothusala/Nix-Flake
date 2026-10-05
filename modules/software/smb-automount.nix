# Automount SMB/CIFS shares on first access. Hosts declare mounts with:
#
#   my.smbMounts."/mnt/share".remote = "//nas.local/share";
#
# Credentials come from the sops secret named by `credentialsSecret`, whose
# content is a mount.cifs credentials file:
#   username=...
#   password=...
#   domain=...      (optional)
{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.smb-automount =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.smbMounts;
      secretNames = lib.unique (lib.mapAttrsToList (_: m: m.credentialsSecret) cfg);
    in
    {
      options.my.smbMounts = lib.mkOption {
        description = "SMB shares to automount, keyed by local mount point.";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              remote = lib.mkOption {
                type = lib.types.str;
                example = "//nas.local/share";
              };
              credentialsSecret = lib.mkOption {
                type = lib.types.str;
                default = "smb-credentials";
                description = "Name of the sops secret holding the credentials file.";
              };
              extraOptions = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        );
      };

      config = lib.mkIf (cfg != { }) {
        environment.systemPackages = [ pkgs.cifs-utils ];

        sops.secrets = lib.genAttrs secretNames (_: { });

        fileSystems = lib.mapAttrs (_: m: {
          device = m.remote;
          fsType = "cifs";
          options = [
            "credentials=${config.sops.secrets.${m.credentialsSecret}.path}"
            "uid=${username}"
            "gid=users"
            "file_mode=0664"
            "dir_mode=0775"
            # Mount lazily; never block boot if the server is unreachable.
            "noauto"
            "nofail"
            "_netdev"
            "x-systemd.automount"
            "x-systemd.idle-timeout=600"
            "x-systemd.device-timeout=5s"
            "x-systemd.mount-timeout=5s"
          ]
          ++ m.extraOptions;
        }) cfg;
      };
    };
}
