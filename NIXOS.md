# NixOS notes

Personal cheat sheet for working with NixOS, flakes and home-manager.
Hostname examples use `krkindwork` and user `kristian`.

- [Rebuilding the system and home](#rebuilding-the-system-and-home)
- [Flake management](#flake-management)
- [Fresh install from a flake](#fresh-install-from-a-flake)
- [Generations and garbage collection](#generations-and-garbage-collection)
- [Ad-hoc shells and dev environments](#ad-hoc-shells-and-dev-environments)
- [direnv](#direnv)
- [Profiles](#profiles)
- [Inspecting the system](#inspecting-the-system)
- [Configuration snippets](#configuration-snippets)
- [Application recipes](#application-recipes)
- [Virtualization (KVM / Windows)](#virtualization-kvm--windows)
- [Misc](#misc)
- [Links](#links)

---

## Rebuilding the system and home

- `nixos-rebuild` applies **system** config.
- `home-manager` applies **user** config.

```bash
# Rebuild and make it the boot default
sudo nixos-rebuild switch --flake .#krkindwork
sudo nixos-rebuild switch --flake ~/dev/nixos-config#${HOSTNAME}

# Activate without making it the boot default (reverts on reboot)
sudo nixos-rebuild test --flake .#krkindwork

# Run as a normal user, elevate only for activation
nixos-rebuild switch --use-remote-sudo
nixos-rebuild test --use-remote-sudo

# Home-manager
home-manager switch --flake .#kristian@krkindwork
```

## Flake management

```bash
nix flake check                  # Evaluate and check the flake
nix flake show                   # List outputs
nix flake update                 # Update all inputs in flake.lock
nix flake update nixpkgs         # Update only one input
nix flake update --commit-lock-file

nix build                        # Build the default package
nix run                          # Run the default app
```

> Before `nix flake update`, check whether a newer NixOS release branch exists
> than the one pinned in `flake.nix` (e.g. `nixos-25.05`) — update doesn't bump
> the branch name.
>
> `nix flake lock --update-input <name>` is the older spelling of
> `nix flake update <name>`.

Error seen when running `nix build` on a flake without a default package:

```
error: flake 'git+file:///home/kristian/Documents/my-flake' does not provide
attribute 'packages.x86_64-linux.default' or 'defaultPackage.x86_64-linux'
```

Fix: add `packages.<system>.default`, or build a named output: `nix build .#<name>`.

### Templates

```bash
nix flake show templates
nix flake init -t templates#simpleContainer
```

### Channels (non-flake)

```bash
nix-channel --update
```

## Fresh install from a flake

From the NixOS ISO:

```bash
sudo su
nix-env -iA nixos.git
git clone <repo url> /mnt/<path>
cd /mnt/<path>
nixos-install --flake .#<hostname>
reboot
```

After the first boot the legacy config is no longer used:

```bash
sudo rm -r /etc/nixos/configuration.nix
```

## Generations and garbage collection

### System generations

```bash
# List
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete all but the current one
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Keep only the last 5
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system

# Delete a specific generation
sudo nix-env --delete-generations <n> --profile /nix/var/nix/profiles/system

# Switch to a specific generation
sudo nix-env --switch-generation <n> --profile /nix/var/nix/profiles/system
```

### Home-manager generations

```bash
home-manager generations
home-manager switch --rollback       # Back to the previous generation
home-manager expire-generations 0d   # Remove all but the current one
```

### Garbage collection

Deleting generations only removes the roots — run GC to actually free space.

```bash
nix-store --gc                   # GC only, keep generations
sudo nix-collect-garbage         # Remove unreferenced store paths
sudo nix-collect-garbage -d      # Also delete all old generations
```

Afterwards, rebuild so the boot menu no longer lists removed generations:

```bash
sudo nixos-rebuild switch --flake .#krkindwork
```

## Ad-hoc shells and dev environments

### nix-shell

```bash
nix-shell -p git ripgrep
nix-shell -p xclip
nix-shell -p python311Packages.pyzmq python311Packages.protobuf python311Packages.setuptools
nix-shell -p python312Packages.serial
```

### nix develop

```bash
nix develop                      # default devShell
nix develop .#default
nix develop .#clang              # named devShell
nix develop -c $SHELL            # Use your own shell (zsh) instead of bash
```

Examples:

```bash
# PlotJuggler workspace
nix develop
cmake -S src/PlotJuggler -B build/PlotJuggler
cmake --build build/PlotJuggler --config RelWithDebInfo

# ATP (Ninja is faster than Make)
nix develop -c $SHELL
mkdir -p build && cd build
cmake .. -G Ninja
ninja

# Generic CMake
cmake -B build -S .
cmake --build build
```

## direnv

Load a flake's devShell automatically when entering a directory. The flakes
live in `../virtualEnvironment/`, relative to each project:

```bash
echo "use flake ../virtualEnvironment/agc_flake" > .envrc        # airolitgroundcontrol
echo "use flake ../virtualEnvironment/cpp_flake" > .envrc        # Generic C++
echo "use flake ../virtualEnvironment/atp_flake" > .envrc        # ATP
echo "use flake ../virtualEnvironment/px4_sitl_flake" > .envrc   # PX4 SITL
echo "use flake ../virtualEnvironment/acc_flake" > .envrc        # ACC
direnv allow
```

```bash
direnv reload                    # e.g. after changing the flake, or from VSCode

# Verify which toolchain is active
which c++
which cmake
ldd $(which cmake)
```

## Profiles

```bash
# Install a package from a local flake
nix profile add /home/kristian/dev/airolit-flake/.#ulog2params

# List installed packages
nix profile list
```

Example output:

```
Name:               home-manager-path
Store paths:        /nix/store/...-home-manager-path
Name:               ulog2params
Flake attribute:    packages.x86_64-linux.ulog2params
```

## Inspecting the system

```bash
nixos-version
nix repl                         # Interactive evaluation; :q to quit
sudo nixos-rebuild edit          # Open /etc/nixos/configuration.nix
```

### Why is a dependency (e.g. Qt5) pulled in?

```bash
HOST=krkindwork

# Build the system toplevel and search its closure
toplvl=$(nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --no-link --print-out-paths)
nix path-info -rsSh "$toplvl" | grep -iE '/(qt5|qt-5|qtbase|qtdeclarative|qtquickcontrols)'

# Interactive tree; search with /
nix run nixpkgs#nix-tree -- "$toplvl"

# Explain the dependency chain
qt5base=$(nix build nixpkgs#qt5.qtbase --no-link --print-out-paths)
nix why-depends "$toplvl" "$qt5base"
```

## Configuration snippets

### Wireshark as a normal user

In use in `nixos/krkindwork/default.nix`.

```nix
nixpkgs.config.allowUnsupportedSystem = true;

security.wrappers.dumpcap = {
  source = "${pkgs.wireshark}/bin/dumpcap";
  owner = "root";
  group = "wireshark";
  capabilities = "cap_net_raw,cap_net_admin+eip";
};

users.groups.wireshark = { };
```

## Application recipes

### AppImages (e.g. QGroundControl)

```bash
chmod +x <file>.AppImage
nix run nixpkgs#appimage-run -- QGroundControl-x86_64.AppImage

# or
nix-shell -p appimage-run
appimage-run <file>.AppImage
```

More info: <https://nixos.wiki/wiki/Appimage>

### SEGGER debugger

```bash
nix-shell -p segger-jlink segger-ozone
```

### Herdr (agent multiplexer)

```bash
# First rebuild compiles Herdr from source
sudo nixos-rebuild switch --flake ~/dev/nixos-config#krkindwork
herdr integration install claude
herdr integration --help
```

To upgrade: change the tag in `flake.nix`, then `nix flake update herdr`.

## Virtualization (KVM / Windows)

Video guide: <https://www.youtube.com/watch?v=FNUQFRXNemw>

### Windows 10 VM in virt-manager

1. Memory 16 GB, 6 CPUs, 60 GiB disk, name `Windows10VM`.
2. Tick **Customize configuration before install**, then:
   - Virtual disk → Disk bus: **VirtIO**
   - Virtual network → Network source: **virtio**
   - TPM → Advanced options: Model **TIS**, Version **2.0**
   - Add Hardware → Storage → Device type **CDROM device** →
     Manage → browse to `virtio-win-0.1.240.iso`
   - Boot Options → enable boot menu; order: SATA CDROM1, VirtIO Disk1
3. Begin install.

**Skip the network requirement during Windows setup:** at "Let's connect to a
network", press `Shift+F10` and run `oobe\bypassnro`. After the reboot, choose
**I don't have internet**.

### "Network 'default' is not active"

```bash
sudo virsh net-start default
sudo virsh net-autostart default   # Start it automatically from now on
```

See: <https://discourse.nixos.org/t/virt-manager-error-starting-domain-requested-operation-is-not-valid-network-default-is-not-active-and-whats-the-equivalent-to-sudo-virsh-net-autostart-network-default/58843>

## Misc

```bash
# Change file owner
chown kristian:users <file>

# SHA256 of a tarball's unpacked contents (for fetchFromGitHub/fetchzip)
nix-prefetch-url --unpack https://github.com/atextor/icat/archive/refs/tags/v0.5.tar.gz --type sha256

# Shallow clone of nixpkgs
git clone https://github.com/NixOS/nixpkgs --depth 1
```

## Links

- <https://mynixos.com/> — search options and packages
- <https://github.com/MatthiasBenaets/nix-config> — example config
  ([video](https://www.youtube.com/watch?v=AGVXJ-TIv3Y))
- <https://github.com/olafkfreund/nix-ai-help>
- <https://github.com/huggingface/tau> — agents
