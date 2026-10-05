<!-- bmad:context -->
<!-- Verified 2026-10-05 against 4ba5325. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## nixos

NixOS dotfiles (channel nixos-25.11, `stateVersion = "25.11"`). This repo is the source of truth; `rebuild.py` deploys components to their system paths. Hyprland uses the master layout on a 3440×1440@144 ultrawide (DP-1).

## Policy

- Edit files only inside this repo. Never edit deployed copies in `~/.config/` or `/etc/nixos/`; change the repo file, then deploy with `rebuild.py`.
- Never run `python rebuild.py --nixos` or `--all` (which includes it): it needs a sudo password and runs `nixos-rebuild switch`. Tell the user to run it.

## Where things are

- `nixos/configuration.nix` imports `hardware-configuration.nix` from `/etc/nixos/` (not in repo). Its TODO says it should be split into components.
- `nvim/` is not managed by `rebuild.py`; the user copies it to `~/.config/nvim/` by hand.

## Running and verifying

- `python rebuild.py --diff -a` shows pending differences without applying. A component flag (`--hyprland`, `--waybar`, `--rofi`, `--kitty`, `--starship`) shows the diff, then asks y/n before copying.
- Dev shell (Python 3.14, `nil`, `nixd`): `nix develop`, or automatic through direnv (`.envrc`).

## Conventions that differ from defaults

- Waybar scripts run from `~/nixos/waybar/` and are referenced that way in `waybar/config.jsonc`, never from `~/.config/waybar/`.
- Volume keys (`hyprland/hyprland.conf`) run `pkill -RTMIN+8 waybar` to refresh `custom/audio`; keep that number in sync with `"signal": 8` in `waybar/config.jsonc`.
- Commit messages are `[tag] lowercase summary`. The tag is free-form by area, for example `config`, `docs`, `feature`, `utils`.

<!-- /bmad:context -->
