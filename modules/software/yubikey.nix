# YubiKey: smartcard (PIV/OpenPGP), FIDO2/U2F and OTP.
# GnuPG's scdaemon has its own CCID driver that grabs the reader exclusively
# and fights with pcscd; we disable it so everything goes through pcscd.
{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.yubikey =
    { pkgs, ... }:
    {
      services.pcscd.enable = true;
      hardware.gpgSmartcards.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];

      programs.gnupg.agent.enable = true;

      environment.systemPackages = with pkgs; [
        yubikey-manager # ykman
        yubikey-personalization
        yubico-piv-tool
        age-plugin-yubikey
        libfido2
      ];

      home-manager.users.${username}.imports = [ hm.yubikey ];
    };

  flake.modules.homeManager.yubikey = {
    programs.gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
        pcsc-shared = true;
      };
    };
  };
}
