# Copilot Instructions for ripxonix

## Architecture Overview

This is a modular NixOS and Home Manager configuration using Nix flakes. The codebase is organized around three core concepts:

### Flake Inputs & Outputs Structure
- **Flake entry point**: [flake.nix](../flake.nix) orchestrates everything using inputs (nixpkgs, home-manager, disko, agenix, etc.)
- **Multi-user, multi-host**: Generates both `nixosConfigurations` (system-level) and `homeConfigurations` (user-level) keyed by hostname
- **Key pattern**: Each configuration receives `extraSpecialArgs` with runtime context: `hostname`, `username`, `desktop`, `stateVersion`, `darkmode`, `platform`

### Directory Organization

**nixos/**: System-level NixOS configurations
- `nixos/default.nix` - Base imports, establishes common settings (timezone, packages, overlays)
- `nixos/{hostname}/` - Host-specific configs (e.g., `krkindwork/`, `mserver/`) import from `_mixins`
- `nixos/_mixins/` - Reusable system modules:
  - `services/` - Systemd services (openssh, syncthing, tailscale, jellyfin, etc.)
  - `desktop/` - Desktop environments (gnome.nix, plasma.nix, xfce.nix with conditional imports)
  - `users/` - Per-user system config
  - `virt/` - Virtualization (libvirtd, QEMU)

**home-manager/**: User-level configurations
- `home-manager/default.nix` - Base, conditionally imports desktop mixins and user-specific modules
- `home-manager/_mixins/console/` - CLI tools, tmux, zsh, git, neovim configs
- `home-manager/_mixins/desktop/` - Desktop environments (mirrors nixos structure)
- `home-manager/_mixins/users/{username}/` - User-specific home manager settings

**pkgs/**: Custom package derivations
- Each subdirectory (e.g., `key_extractor/`, `feed_fencer/`) is a callPackage
- Exported in [pkgs/default.nix](../pkgs/default.nix), accessible as custom packages throughout configs

**overlays/**: Nixpkgs modifications
- `additions` - Custom packages from `pkgs/`
- `modifications` - Overrides to existing nixpkgs
- `unstable-packages` - Access nixpkgs-unstable via `pkgs.unstable.*`

**secrets/**: Age-encrypted secrets (agenix)
- Keys stored at `~/.local/keys/agenix`
- Currently disabled; enable by uncommenting in [secrets/default.nix](../secrets/default.nix)

## Key Workflows

### Building Configurations
All commands assume `~/dev/nixos-config` as working directory. See [Makefile](../Makefile):

```bash
make os                    # Rebuild NixOS: sudo nixos-rebuild switch --flake .#${HOSTNAME}
make home                  # Apply Home Manager: home-manager switch --flake ~/.../#{USER}@{HOSTNAME}
make home light            # Override darkmode_flag to light
make iso                   # Build ISO image
```

Home Manager automatically applies overlays and uses `stateVersion = "25.05"` for generational tracking.

### Adding New Host
1. Create `nixos/{hostname}/default.nix` with imports from `_mixins`
2. Add `nixosConfigurations.{hostname}` entry in [flake.nix](../flake.nix) with `extraSpecialArgs`
3. Create corresponding `home-manager/_mixins/users/{username}/` if user-specific config needed

### Adding New Service
1. Create `nixos/_mixins/services/{service}.nix`
2. Import in host config (e.g., `nixos/krkindwork/default.nix`)
3. Use conditional imports: `lib.optional (builtins.isString desktop) ./_mixins/desktop`

## Critical Patterns & Conventions

### Conditional Imports
Always use `lib.optional` for optional config sections:
```nix
# From home-manager/default.nix - only imports desktop if passed as extraSpecialArgs
++ lib.optional (builtins.isString desktop) ./_mixins/desktop
++ lib.optional (builtins.isPath (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
```

This avoids evaluation errors if files don't exist.

### Context Passing
System and home configs receive identical context vars:
- `hostname` - Machine name (used for `networking.hostName`)
- `username` - User (used for home directory paths)
- `desktop` - String env name ("gnome", "plasma", "xfce") or null
- `stateVersion` - Generational tracking (currently "25.05")
- `darkmode` - Boolean from [darkmode_flag input](../flake.nix#L29)

Reference via `{ hostname, desktop, ... }` destructuring.

### Overlays & Package Access
- Custom packages from `pkgs/` are injected as overlay `additions`
- Unstable packages accessible via `pkgs.unstable.*` (e.g., `pkgs.unstable.nix`)
- All configs have overlays in `nixpkgs.overlays` section

### Home Manager Organization
- Base [home-manager/default.nix](../home-manager/default.nix) handles common setup
- Console tools in [home-manager/_mixins/console/default.nix](../home-manager/_mixins/console/default.nix)
- Each service/tool has own mixin file (e.g., `tmux.nix`, `zsh.nix`, `git.nix`)
- Starship config loaded as file: `"${config.xdg.configHome}/starship.toml"` (not inline)

## External Dependencies & Integration Points

- **disko** - Declarative disk partitioning (imported as nixosModule)
- **agenix** - Age-encrypted secrets management, identity at `~/.local/keys/agenix`
- **nixos-hardware** - Hardware-specific configs (imported for device compatibility)
- **talon-nix** - Voice control integration (available as input, not actively used)
- **nixos-generators** - ISO/VM image generation
- **nix-formatter-pack** - Nix code formatting (formatter set per system)

## Testing & Validation

- Use `nix flake check` to validate flake structure
- Format with `nix fmt` (uses nixpkgs-fmt)
- Dry-run before apply: `nixos-rebuild switch --flake . --dry-run`
- Home Manager backup: `--flake` flag automatically creates `backup-` symlink of previous gen
