# Enables `flake.modules.<class>.<name>` — the registry every other file
# contributes to. Hosts later pick entries out of it by name.
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
