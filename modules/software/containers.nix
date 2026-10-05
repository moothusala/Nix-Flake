# OCI containers: rootless Podman with a Docker-compatible CLI and socket.
{
  flake.modules.nixos.containers =
    { pkgs, ... }:
    {
      virtualisation.containers.enable = true;
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune.enable = true;
      };

      environment.systemPackages = with pkgs; [
        podman-compose
        podman-tui
        buildah
        skopeo
        dive
      ];
    };
}
