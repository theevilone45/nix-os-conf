# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A NixOS dotfiles/configuration repository. Config files live here as the source of truth and are deployed to their system locations via `rebuild.py`.

## Applying changes

`rebuild.py` copies configs from this repo to system paths and optionally triggers `nixos-rebuild switch`. Run it from the repo root:

```bash
# Show what would change (diff only, no apply)
python rebuild.py --diff -a

# Apply a specific component
python rebuild.py --nixos       # copies to /etc/nixos/configuration.nix + nixos-rebuild switch (needs sudo)
python rebuild.py --hyprland    # copies to ~/.config/hypr/
python rebuild.py --waybar      # copies to ~/.config/waybar/
python rebuild.py --rofi        # copies to ~/.config/rofi/
python rebuild.py --kitty       # copies to ~/.config/kitty/
python rebuild.py --starship    # copies to ~/.config/starship/starship.toml

# Apply all
python rebuild.py --all
```

The script shows a diff and prompts for confirmation before applying. The `--diff` flag shows differences without prompting to apply.

Neovim config (`nvim/`) is **not** managed by `rebuild.py` — it must be copied manually to `~/.config/nvim/`.

## Dev shell

The `flake.nix` defines a dev shell with Python 3.14, `nil`, and `nixd` (Nix LSP tools). Enter it with:

```bash
nix develop
# or automatically via direnv (configured in .envrc)
```

## Architecture

| Path | Deployed to | Notes |
|------|-------------|-------|
| `nixos/configuration.nix` | `/etc/nixos/configuration.nix` | Main NixOS config; imports `hardware-configuration.nix` from `/etc/nixos/` (not in repo) |
| `hyprland/` | `~/.config/hypr/` | Hyprland WM + hyprpaper wallpaper config |
| `waybar/` | `~/.config/waybar/` | Status bar; custom modules use scripts in `waybar/*.sh` executed directly from `~/nixos/waybar/` |
| `rofi/` | `~/.config/rofi/` | App launcher |
| `kitty/` | `~/.config/kitty/` | Terminal emulator |
| `starship/starship.toml` | `~/.config/starship/starship.toml` | Shell prompt |
| `nvim/` | `~/.config/nvim/` | Neovim config with lazy.nvim |

### Key details

- NixOS channel: `nixos-unstable`; `stateVersion = "25.11"`
- Hyprland uses **master layout** (not dwindle) with a 3440×1440@144 ultrawide monitor on DP-1
- Waybar's `custom/audio` module runs `waybar/audio_status.sh` from `~/nixos/waybar/` directly — not from `~/.config/waybar/` — so that path is hardcoded in `waybar/config.jsonc`
- Volume keys send `SIGRTMIN+8` to waybar to trigger a live refresh of the audio module
- The `nixos/configuration.nix` TODO notes it should be split into components
