# Machine-specific settings for Norn.
{
  flake.modules.nixos.host-Norn = {
    networking.hostName = "Norn";

    my.smbMounts."/mnt/share".remote = "//192.168.1.204/data";

    # Release of the installer used for this machine; never change it after install.
    system.stateVersion = "26.05";
  };
}
