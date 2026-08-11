# wlm-iii/nixos-config

My humble NixOS + Home Manager configuration

Built with flake-parts, flake-file, import-tree, and inspired by [Dendritic Design](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)

## Structure

- `/modules/hosts/`: host-specific hardware and configuration
- `/modules/users/`: users and user-specific configuration
- `/modules/system/profiles/`: profiles for system configuration (cli, desktop, etc.)
- `/modules/system/settings/`: reusable, host-agnostic hardware and system configuration
- `/modules/services/`: NixOS service modules
- `/modules/programs/`: NixOS and Home Manager programs

## Usage

Regenerate `flake.nix` when changing flake-file input or output:
```sh
nix run .#write-flake
```

Build with:
```sh
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

or on NixOS:
```sh
nixos-rebuild build --flake .#<host>
```
