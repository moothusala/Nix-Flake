# Standard partition layout addressed by filesystem label, so hosts don't need
# per-install UUIDs. Create the partitions with matching labels:
#   mkfs.fat -F 32 -n BOOT /dev/<esp>
#   mkfs.ext4 -L nixos     /dev/<root>
#   mkswap -L swap         /dev/<swap>
{
  flake.modules.nixos.disk-labels = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  };
}
