# Latest stable .NET SDK.
{
  flake.modules.nixos.dotnet =
    { pkgs, ... }:
    let
      sdk = pkgs.dotnetCorePackages.sdk_10_0;
    in
    {
      environment.systemPackages = [ sdk ];
      environment.sessionVariables = {
        DOTNET_ROOT = "${sdk}/share/dotnet";
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
      };

      # `dotnet tool install` and NuGet packages ship generic-Linux binaries.
      programs.nix-ld.enable = true;
    };
}
