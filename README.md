# NixFlake

Dendritic NixOS configuration built on [flake-parts] + [import-tree].

Every `.nix` file under `modules/` and `machines/` is a flake-parts module and
is loaded automatically. There are no import lists to maintain. Each file
contributes named NixOS (and Home Manager) modules to the registry
`flake.modules.<class>.<name>`, and each host picks the ones it wants by name.
To disable a file without deleting it, prefix its name (or its folder's name)
with `_`.

```
flake.nix                 inputs + import-tree ./modules ./machines
.sops.yaml                who can decrypt secrets (admin + each host)
secrets/secrets.yaml      sops-encrypted secrets
modules/
  flake/                  flake-parts plumbing, shared facts (meta.nix), dev shell
  system/                 OS settings: nix, boot, locale, networking, sops, users, home-manager
  software/               one file per program/service (nixos + homeManager halves)
  profiles/               opt-in bundles: profile-base, profile-desktop, profile-development
machines/
  testVM-01/
    default.nix           nixosConfiguration + this host's module list
    configuration.nix     hostname, stateVersion, SMB mounts, other per-host settings
    hardware.nix          from nixos-generate-config
```

## Modules

| Name | What it does |
|---|---|
| `nix-settings` | flakes, weekly GC, store optimisation, allowUnfree |
| `boot-efi` | systemd-boot, latest kernel |
| `locale` | timezone/locale from `meta.nix` |
| `networking` | NetworkManager, firewall, Avahi (`<host>.local`) |
| `sops` | sops-nix, decrypting with the host's SSH host key |
| `users` | `moothusala`: wheel, password from sops (same everywhere), SSH key, passwordless sudo, `mutableUsers = false` |
| `home-manager` | Home Manager for the primary user |
| `openssh` | sshd, key-only, no root login |
| `git`, `zsh`, `fzf`, `lazygit`, `alacritty` | installed + configured for the user |
| `nvim` | system Neovim, default editor, vi/vim aliases |
| `lazyvim` | LazyVim via [lazyvim-nix] (declarative plugins, no Mason) |
| `wayland` | graphics, portals, polkit, keyring, fonts, `NIXOS_OZONE_WL` |
| `niri` | niri + greetd/tuigreet login |
| `niri-software-render` | **VMs only**: rebuilds niri so it accepts the CPU renderer (llvmpipe) on GPU-less hosts like Hyper-V |
| `noctalia` | Noctalia shell as a systemd user service |
| `pipewire` | PipeWire with ALSA/Pulse/JACK, rtkit |
| `yubikey` | pcscd, udev rules, ykman/PIV/FIDO2 tools, gpg agent; scdaemon `disable-ccid` so it doesn't fight pcscd |
| `vscode` | VS Code (FHS build so marketplace extensions work) |
| `dotnet` | latest stable .NET SDK, `DOTNET_ROOT`, nix-ld |
| `python` | python3 + pip/virtualenv, uv |
| `containers` | rootless Podman, `docker` CLI/socket compat, compose, buildah, skopeo |
| `smb-automount` | adds the `my.smbMounts` option (systemd automount, never blocks boot) |

Profiles: `profile-base` must be on every host. `profile-desktop` and
`profile-development` are opt-in. Don't also list a module that's already
in a profile you include, or it gets imported twice.

## Adding things

**A new program:** create `modules/software/foo.nix`:

```nix
{
  flake.modules.nixos.foo = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.foo ];
  };
}
```

Then add `foo` to a profile or to a host's list. If it needs dotfiles, copy the
pattern in `git.nix` (a `homeManager.foo` half wired into
`home-manager.users.<user>`).

**A new host** (e.g. a server):

1. Create `machines/<name>/` with `default.nix`, `configuration.nix`, and
   `hardware.nix` (copy testVM-01's files). For a server, use only
   `profile-base` plus whatever else it needs.
2. Install NixOS on the machine, then get its age recipient:
   `ssh-keyscan -t ed25519 <ip> | ssh-to-age`
3. Add that recipient to `.sops.yaml` (under `keys:` and the creation rule),
   then run `sops updatekeys secrets/secrets.yaml`.
4. `git add` the new files. Flakes only see files git tracks.

## Secrets (sops-nix) from Windows

Everything runs in WSL. Run `nix develop` in this directory to get `sops`,
`age`, `ssh-to-age`, and `mkpasswd`.

- Your admin age key is in WSL at `~/.config/sops/age/keys.txt`. **Back it
  up** (e.g. in a password manager). Without it, the only way to edit secrets
  is from a host.
- Edit secrets: `sops secrets/secrets.yaml`
- Contents:
  - `users.moothusala.hashedPassword`: generate with `mkpasswd -m yescrypt`
  - `smb-credentials`: a mount.cifs credentials file (`username=`, `password=`, optional `domain=`)

## Before the first deploy

1. **Set the password hash.** It's currently `!` (locked). SSH with your key
   and sudo will still work, but you can't log in at the console or greeter
   until you set it:
   `sops secrets/secrets.yaml` → paste the `mkpasswd -m yescrypt` output.
2. **Set the SMB share** in `machines/testVM-01/configuration.nix` and the
   real credentials in `smb-credentials`.
3. Set your git name in `modules/flake/meta.nix` (`fullName`) if it should
   be something other than `moothusala`.

## Deploying

Build in WSL and push to the VM over SSH. The VM doesn't need flakes
enabled for this first deploy:

```bash
nix run nixpkgs#nixos-rebuild -- switch --flake .#testVM-01 --target-host moothusala@<vm-ip> --sudo --ask-sudo-password
```

After that, sudo is passwordless and only your key can SSH in, so
`--ask-sudo-password` is no longer needed. You can also clone the repo onto
the machine and run `sudo nixos-rebuild switch --flake .#testVM-01`.

Notes:
- The hostname changes from `vm-nixos1` to `testVM-01`. Its mDNS name becomes `testVM-01.local`.
- Password SSH logins are disabled after the switch. Make sure your key
  works first: `ssh -i <key> moothusala@<vm-ip>`.
- Stock niri refuses CPU-only rendering, so a GPU-less VM gets a black
  screen. testVM-01 includes `niri-software-render` to work around this.
  Leave it off hosts with a real GPU. If a session fails, check
  `journalctl --user -b -u niri`.

## Maintenance

```bash
nix flake update                    # bump all inputs
nix flake check                     # evaluate every host
nix fmt                             # format with nixfmt
```

[flake-parts]: https://flake.parts
[import-tree]: https://github.com/vic/import-tree
[lazyvim-nix]: https://github.com/pfassina/lazyvim-nix
