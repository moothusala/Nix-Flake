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

      # branchlet isn't in nixpkgs. Upstream builds with bun, but its npm
      # tarball ships a self-contained bundle, so only node is needed.
      branchlet = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "branchlet";
        version = "1.2.0";
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/branchlet/-/branchlet-${finalAttrs.version}.tgz";
          hash = "sha256-j1NhVt1TLt1bRhNZ3JKYktheM1K1gTTEnVcbb5YUJhs=";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/lib/branchlet
          cp -r dist package.json schema.json $out/lib/branchlet/
          makeWrapper ${pkgs.lib.getExe pkgs.nodejs} $out/bin/branchlet \
            --add-flags $out/lib/branchlet/dist/index.js \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git ]}
        '';
        meta.mainProgram = "branchlet";
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
        branchlet
        navi
        tealdeer
        hygg
        discordo
        lynx
        ncdu
      ];

      home-manager.users.${username}.imports = [ hm.tui-tools ];
    };

  # zoxide needs its shell hook, which Home Manager adds to zsh.
  flake.modules.homeManager.tui-tools = {
    programs.zoxide.enable = true;
  };
}
