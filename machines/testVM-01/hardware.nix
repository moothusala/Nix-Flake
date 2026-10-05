# From nixos-generate-config on testVM-01 (was vm-nixos1).
# Regenerate with `nixos-generate-config --show-hardware-config` and paste
# the body back in here if disks change.
{
  flake.modules.nixos.host-testVM-01 =
    { lib, ... }:
    {
      boot.initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/9d5c12f0-38e9-44c7-bb8c-e8ca7c4a8b34";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D512-CB43";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/0da0945a-1e79-4761-b880-4a696af429fb"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      virtualisation.hypervGuest.enable = true;
    };
}
