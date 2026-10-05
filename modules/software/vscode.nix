# FHS-wrapped VS Code so marketplace extensions (C# Dev Kit, Python, etc.)
# that ship their own native binaries work without extra packaging.
{
  flake.modules.nixos.vscode =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.vscode.fhs ];
    };
}
