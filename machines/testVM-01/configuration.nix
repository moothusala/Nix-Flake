# Machine-specific settings for testVM-01.
{
  flake.modules.nixos.host-testVM-01 = {
    networking.hostName = "testVM-01";

    # SMB share. TODO: set the real server/share; credentials are the
    # `smb-credentials` sops secret.
    my.smbMounts."/mnt/share".remote = "//192.168.1.204/data";

    # First NixOS release installed on this machine; never change it.
    system.stateVersion = "26.05";
  };
}
