{
  flake.modules.nixos.boot-efi =
    { lib, pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = lib.mkDefault 20;

      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
}
