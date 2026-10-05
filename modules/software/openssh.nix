{
  flake.modules.nixos.openssh = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        # Key-only logins; the primary user's key is installed by `users`.
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
