# VM-only: let niri run on Mesa's CPU renderer (llvmpipe).
# Stock niri refuses software EGL devices (src/backend/tty.rs), which leaves
# GPU-less VMs such as Hyper-V with a black screen. This rebuilds niri with
# that check disabled. Rendering is slow and upstream cites crash risks when
# importing dmabufs, so only add this to hosts without a real GPU.
{
  flake.modules.nixos.niri-software-render =
    { pkgs, ... }:
    {
      programs.niri.package = pkgs.niri.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/backend/tty.rs \
            --replace-fail '!egl_device.is_software(),' 'true || !egl_device.is_software(),'
        '';
        # Upstream's test suite adds a lot of build time and nothing for this patch.
        doCheck = false;
      });
    };
}
