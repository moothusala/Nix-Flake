{ config, ... }:
let
  inherit (config.meta) timeZone locale;
in
{
  flake.modules.nixos.locale =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault timeZone;
      i18n.defaultLocale = lib.mkDefault locale;
      console.keyMap = lib.mkDefault "us";
    };
}
