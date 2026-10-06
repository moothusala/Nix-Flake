# NixFlake

Dendritic NixOS configuration built on [flake-parts] + [import-tree].

Every `.nix` file under `modules/` and `machines/` is a flake-parts module and
is loaded automatically. There are no import lists to maintain. Each file
contributes named NixOS (and Home Manager) modules to the registry
`flake.modules.<class>.<name>`, and each host picks the ones it wants by name.
To disable a file without deleting it, prefix its name (or its folder's name)
with `_`. Non-Nix assets live in `_`-prefixed folders for the same reason
(e.g. `modules/software/_niri/config.kdl`).

```
flake.nix                 inputs + import-tree ./modules ./machines
.sops.yaml                who can decrypt secrets (admin + each host)
secrets/secrets.yaml      sops-encrypted secrets
modules/
  flake/                  flake-parts plumbing, shared facts (meta.nix), dev shell
  system/                 OS settings: nix, boot, locale, networking, sops, users,
                          home-manager, laptop, wifi-home, disk-labels
  software/               one file per program/service (nixos + homeManager halves)
  profiles/               opt-in bundles (see below)
machines/
  <host>/
    default.nix           nixosConfiguration + this host's module list
    configuration.nix     hostname, stateVersion, SMB mounts, other per-host settings
    hardware.nix          kernel modules, nixos-hardware profile, (VM: filesystems)
```

## Hosts

| Host | Hardware | Profiles |
|---|---|---|
| `testVM-01` | Hyper-V VM, headless (SSH only) | base, development |
| `Oberon` | Lenovo ThinkPad T460s | base, desktop, development, laptop |
| `Norn` | Panasonic Let's Note CF-SV7 | base, desktop, development, laptop |

All three also include `smb-automount`. The laptops include `disk-labels`.

## Profiles

| Profile | Modules |
|---|---|
| `profile-base` (every host) | nix-settings, boot-efi, locale, networking, sops, users, home-manager, openssh, zsh, git, fzf, nvim |
| `profile-desktop` | wayland, niri, noctalia, pipewire, alacritty, vscode, yubikey |
| `profile-development` (CLI only) | lazyvim, lazygit, dotnet, python, containers |
| `profile-laptop` | laptop, wifi-home |

Don't also list a module that's already in a profile you include, or it gets
imported twice.

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
| `openssh` | sshd on port 22 (firewall opened), key-only, no root login |
| `laptop` | Wi-Fi/BT firmware, upower, thermald, fwupd, lid-close suspend, zram |
| `wifi-home` | NetworkManager profiles for `Wasabi_Fast` (preferred) and `Wasabi`; passphrases from sops |
| `disk-labels` | `/` = `nixos`, `/boot` = `BOOT`, swap = `swap`, all by filesystem label |
| `git`, `zsh`, `fzf`, `lazygit`, `alacritty` | installed + configured for the user |
| `nvim` | system Neovim, default editor, vi/vim aliases |
| `lazyvim` | LazyVim via [lazyvim-nix] (declarative plugins, no Mason) |
| `wayland` | graphics, portals, polkit, keyring, fonts, `NIXOS_OZONE_WL` |
| `niri` | niri + greetd/tuigreet login + the user's niri config (`_niri/config.kdl`) |
| `niri-software-render` | VMs only: rebuilds niri so it accepts the CPU renderer on GPU-less hosts. Not used by any host right now |
| `noctalia` | Noctalia shell as a systemd user service |
| `pipewire` | PipeWire with ALSA/Pulse/JACK, rtkit |
| `yubikey` | pcscd, udev rules, ykman/PIV/FIDO2 tools, gpg agent; scdaemon `disable-ccid` so it doesn't fight pcscd |
| `vscode` | VS Code (FHS build so marketplace extensions work) |
| `dotnet` | latest stable .NET SDK, `DOTNET_ROOT`, nix-ld |
| `python` | python3 + pip/virtualenv, uv |
| `containers` | rootless Podman, `docker` CLI/socket compat, compose, buildah, skopeo |
| `smb-automount` | adds the `my.smbMounts` option (systemd automount, never blocks boot) |

### niri (laptops)

The config in `modules/software/_niri/config.kdl` sets up niri's scrolling
layout:
- New windows open as columns to the right, at half width by default.
  `Mod+R` cycles through 1/3, 1/2, 2/3 and full width.
- Touchpad: two-finger natural scrolling, tap-to-click, ignores the touchpad
  while you type. Gestures: 3-finger swipe left/right scrolls columns,
  up/down switches workspaces, 4-finger swipe opens the overview.
- TrackPoint: hold the middle button and move to scroll.
- Mouse wheel: `Mod+wheel` scrolls between columns, `Mod+Shift+wheel`
  switches workspaces.
- Noctalia keys: `Mod+Space` or `Mod+D` opens the launcher, `Mod+S` the
  control center, `Mod+Shift+,` settings, `Super+Alt+L` locks the screen.
  Volume, brightness and media keys go through Noctalia.
- `Mod+T` opens a terminal. `Mod+Shift+/` shows all keybinds.

The file is managed by Home Manager, so edit it in the repo, not on the
machine. Check your changes with `niri validate -c modules/software/_niri/config.kdl`.

## Secrets (sops-nix) from Windows

Everything runs in WSL. Run `nix develop` in this directory to get `sops`,
`age`, `ssh-to-age`, and `mkpasswd`.

- **Admin key:** `~/.config/sops/age/keys.txt` in WSL. It's the only key
  that can edit secrets, so **back it up**. Machines don't need it; each
  host decrypts with its own SSH host key.
- **Edit secrets:** `sops secrets/secrets.yaml` (opens in `$EDITOR`).
  Commit and push afterwards, then rebuild the hosts.
- **Contents:**
  - `users.moothusala.hashedPassword`: generate with `mkpasswd -m yescrypt`
  - `smb-credentials`: a mount.cifs credentials file (`username=`, `password=`, optional `domain=`)
  - `wifi-env`: Wi-Fi passphrases (see below)

### Adding the Wi-Fi passphrases

In WSL:

```bash
cd /mnt/d/github/nix/NixFlake && nix develop
sops secrets/secrets.yaml
```

Replace the `CHANGEME` values in the `wifi-env` block, keeping the
indentation:

```yaml
wifi-env: |
    WASABI_PSK=your-wasabi-passphrase
    WASABI_FAST_PSK=your-wasabi-fast-passphrase
```

If a passphrase contains spaces, `$`, `"` or `\`, wrap it in single quotes:
`WASABI_PSK='pa$$ word'`. Save, then `git commit -am "Set Wi-Fi keys" && git push`.
The laptops pick it up on their next rebuild or install.

## Host keys

Each host has an SSH host key (`/etc/ssh/ssh_host_ed25519_key`) that does two
jobs. It's the host's identity for SSH, and its age form is the host's sops
recipient in `.sops.yaml`.

- **testVM-01:** uses the key generated when NixOS was installed.
- **Oberon / Norn:** keys were pre-generated in
  `D:\github\nix\host-keys\<host>\`, so their sops recipients were known
  before install. Copy them onto the machine during install (step 4 below).
  After both laptops are installed, move that folder to safe storage or
  delete it. Anyone holding a host key can decrypt the secrets.

**Your SSH key** (`modules/flake/meta.nix`) is installed for `moothusala`
on every host, so nothing needs copying. Use the matching private key in WSL
(`~/.ssh/id_ed25519`) or Windows (`C:\Users\<you>\.ssh\id_ed25519`).

## Installing a laptop (Oberon / Norn)

Use the NixOS 26.05 installer (minimal ISO is fine). Boot it in UEFI mode.
Commands below use `Oberon`; swap in `Norn` for the other machine.

**1. Get online.**

```bash
sudo nmcli device wifi connect Wasabi_Fast password '<passphrase>'
```

**2. Allow SSH into the installer** so you can paste commands and copy the
host key from WSL:

```bash
passwd          # set a temporary password for the `nixos` user
ip -4 addr      # note the laptop's IP
```

**3. Partition and format.** Find the disk with `lsblk`: the T460s is usually
`/dev/nvme0n1` or `/dev/sda`. NVMe partitions are named `p1`, `p2`, …;
SATA disks use `1`, `2`, …. **This erases the disk.**

```bash
DISK=/dev/nvme0n1
sudo parted $DISK -- mklabel gpt
sudo parted $DISK -- mkpart ESP fat32 1MiB 1GiB
sudo parted $DISK -- set 1 esp on
sudo parted $DISK -- mkpart swap linux-swap 1GiB 9GiB
sudo parted $DISK -- mkpart root ext4 9GiB 100%
sudo mkfs.fat -F 32 -n BOOT ${DISK}p1
sudo mkswap -L swap ${DISK}p2
sudo mkfs.ext4 -L nixos ${DISK}p3
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/BOOT /mnt/boot
sudo swapon /dev/disk/by-label/swap
```

The labels must be exactly `BOOT`, `nixos` and `swap`, because `disk-labels`
mounts by label. That way no UUIDs need to go in the repo.

**4. Copy the pre-generated host key** from WSL to the installer:

```bash
scp /mnt/d/github/nix/host-keys/Oberon/ssh_host_ed25519_key* nixos@<laptop-ip>:/tmp/
```

Then on the laptop:

```bash
sudo mkdir -p /mnt/etc/ssh
sudo install -m 600 /tmp/ssh_host_ed25519_key /mnt/etc/ssh/
sudo install -m 644 /tmp/ssh_host_ed25519_key.pub /mnt/etc/ssh/
```

**5. Check the kernel modules.**

```bash
nixos-generate-config --root /mnt --show-hardware-config | grep -A3 availableKernelModules
```

If that lists modules missing from `machines/Oberon/hardware.nix`, add them,
then commit and push before continuing. Ignore the `fileSystems` lines it
prints; `disk-labels` handles those.

**6. Install** (no root password; you log in as `moothusala`):

```bash
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake github:moothusala/Nix-Flake#Oberon --no-root-passwd
sudo reboot
```

**7. After the first boot,** log in at tuigreet as `moothusala`. Wi-Fi
connects on its own. From WSL, `ssh moothusala@oberon.local` should work with
your key and no password. Later updates are run on the laptop:

```bash
sudo nixos-rebuild switch --flake github:moothusala/Nix-Flake#Oberon --refresh
```

## Adding a new host (e.g. a server)

1. Create `machines/<name>/` with `default.nix`, `configuration.nix` and
   `hardware.nix` (copy an existing host). For a server, use only
   `profile-base` plus whatever else it needs.
2. Give it a sops recipient. Either pre-generate a host key, as was done
   for the laptops:
   ```bash
   mkdir -p /mnt/d/github/nix/host-keys/<name>
   ssh-keygen -t ed25519 -N "" -C root@<name> -f /mnt/d/github/nix/host-keys/<name>/ssh_host_ed25519_key
   ssh-to-age -i /mnt/d/github/nix/host-keys/<name>/ssh_host_ed25519_key.pub
   ```
   or, for a machine that's already running, use `ssh-keyscan -t ed25519 <ip> | ssh-to-age`.
3. Add the `age1…` recipient to `.sops.yaml` (under `keys:` and the creation
   rule), then run `sops updatekeys secrets/secrets.yaml`.
4. `git add` the new files (flakes only see files git tracks), then commit and push.

## Maintenance

```bash
nix flake update                    # bump all inputs
nix flake check                     # evaluate every host
nix fmt                             # format with nixfmt
```

[flake-parts]: https://flake.parts
[import-tree]: https://github.com/vic/import-tree
[lazyvim-nix]: https://github.com/pfassina/lazyvim-nix
