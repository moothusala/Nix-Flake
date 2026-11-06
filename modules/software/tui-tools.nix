# Terminal apps for the laptops. lazygit is in `profile-development`.
{ config, ... }:
let
  inherit (config.meta) username;
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.tui-tools =
    { pkgs, ... }:
    let
      # mdt (crate `mdtui`) isn't in nixpkgs.
      mdt = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "mdtui";
        version = "0.3.0";
        src = pkgs.fetchFromGitHub {
          owner = "PPRAMANIK62";
          repo = "mdt";
          tag = "v${finalAttrs.version}";
          hash = "sha256-UZ6/QPyUBGvCWvmiPhsvhnxKxG5KIwUvQQlPi2XreaM=";
        };
        cargoHash = "sha256-aT6SNfh0i2StCcbygcTcIUXG+sxyqyEfZ6swR1Id1fE=";
        meta.mainProgram = "mdt";
      });
    in
    {
      environment.systemPackages = with pkgs; [
        mdt
        harlequin
        k9s
        kubescape
        yazi
        superfile
        posting
        jq
        tuicr
      ];

      home-manager.users.${username}.imports = [ hm.tui-tools ];
    };

  # zoxide needs its shell hook, which Home Manager adds to zsh.
  flake.modules.homeManager.tui-tools = {
    programs.zoxide.enable = true;
  };
}
