{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      # `nix develop` in WSL/Linux gives the tools needed to manage secrets.
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          sops
          age
          ssh-to-age
          mkpasswd
        ];
      };
    };
}
