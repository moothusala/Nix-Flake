# Machine-specific settings for Oberon.
{
  flake.modules.nixos.host-Oberon = {
    networking.hostName = "Oberon";

    my.smbMounts."/mnt/share".remote = "//192.168.1.204/data";

    # Release of the installer used for this machine; never change it after install.
    system.stateVersion = "26.05";
  };
}
