# Panasonic Let's Note CF-SV7 (8th-gen Intel "Kaby Lake R"). nixos-hardware
# has no CF-SV7 profile, so compose the generic Intel CPU/GPU, laptop and SSD
# modules. Filesystems come from `disk-labels`.
# During install, compare with `nixos-generate-config --show-hardware-config`
# and copy over any extra initrd modules it lists.
{ inputs, ... }:
{
  flake.modules.nixos.host-Norn =
    { lib, ... }:
    {
      imports = [
        "${inputs.nixos-hardware}/common/cpu/intel/kaby-lake"
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      boot.kernelModules = [ "kvm-intel" ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
