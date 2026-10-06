# Lenovo ThinkPad T460s (Skylake). Filesystems come from `disk-labels`.
# During install, compare with `nixos-generate-config --show-hardware-config`
# and copy over any extra initrd modules it lists.
{ inputs, ... }:
{
  flake.modules.nixos.host-Oberon =
    { lib, ... }:
    {
      imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t460s ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.kernelModules = [ "kvm-intel" ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
