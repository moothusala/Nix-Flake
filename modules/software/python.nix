{
  flake.modules.nixos.python =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            pip
            virtualenv
          ]
        ))
        uv
      ];
    };
}
