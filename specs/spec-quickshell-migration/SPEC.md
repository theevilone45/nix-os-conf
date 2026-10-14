---
id: SPEC-quickshell-migration
companions: []
sources: []
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Quickshell Desktop Shell Migration

## Why

A vision and consolidation effort for a single-user NixOS/Hyprland desktop (3440×1440 ultrawide). The shell is split across waybar, three rofi-dmenu shell scripts, rofi's launcher, and hyprpaper. Each has its own config, theme and refresh hack (`pkill -RTMIN+8 waybar`), and the panels are text menus without sliders or per-app control. Quickshell gives one declaratively styled QML shell for bar, panels, launcher, wallpaper and lock screen, deployable through the existing `rebuild.py` workflow.

## Capabilities

- **CAP-1**
  - **intent:** The shell paints the desktop wallpaper on DP-1, replacing hyprpaper.
  - **success:** With hyprpaper stopped, `~/Wallpapers/Unkown.jpg` shows on DP-1 after login. Changing the configured path and reloading changes the image without restarting Hyprland.
- **CAP-2**
  - **intent:** The user can lock the session and unlock it with their password; nothing is visible or interactive until authentication.
  - **success:** A wrong password stays locked, the correct one unlocks, and windows are neither visible nor clickable while locked.
- **CAP-3**
  - **intent:** The user can shut down, reboot or lock from one power panel.
  - **success:** Each entry performs its action.
- **CAP-4**
  - **intent:** The user can see and set output volume and mute, choose the default output, and adjust per-application stream volume.
  - **success:** Changing the default output moves existing streams to it. Volume keys and the panel stay in sync with no signal hack.
- **CAP-5**
  - **intent:** The user can see paired Bluetooth devices, connect or disconnect them, and switch the audio profile of a connected device.
  - **success:** After connecting a headset its profiles appear within about 2 s. Selecting one applies it, and the active one is marked.
- **CAP-6**
  - **intent:** The user can read time and date at a glance and open a month calendar.
  - **success:** The clock shows the current time. The calendar shows the current month with today highlighted.
- **CAP-7**
  - **intent:** A minimal bar shows workspaces and the clock and hosts the entry points to the panels.
  - **success:** Workspace switching state is reflected live, and every panel (CAP-3, 4, 5, 6) opens from the bar.
- **CAP-8**
  - **intent:** The user can search and launch installed applications, replacing rofi drun.
  - **success:** SUPER+R opens the launcher, typing filters installed apps, Enter launches the selection, and Esc closes it.

## Constraints

- Edit only repo files and deploy through `rebuild.py` with a new Quickshell component; never edit `~/.config/` directly.
- Never run `nixos-rebuild`: package and service changes go in `nixos/configuration.nix` and the user applies them.
- NixOS 25.11 channel: Quickshell must come from that channel or a pinned flake input.
- Single target: Hyprland on DP-1 at 3440×1440@144. No multi-monitor or laptop support.
- The session lock must use `ext-session-lock`, so a crashed lock surface cannot expose the session.
- Audio goes through PipeWire/WirePlumber and Bluetooth through BlueZ, using native Quickshell services; no new shell-script backends.
- waybar, rofi and hyprpaper are removed only after parity, so the desktop is never left without a bar or wallpaper.

## Non-goals

- No widget kit or general theming framework.
- No notifications, tray or OSD; dunst stays.
- No Bluetooth scan or pairing; that stays in blueman.
- Waybar's CPU, temperature, RAM, network and window-title modules are dropped on purpose.
- No multi-monitor support.
- No SDDM login-screen replacement.

## Success signal

After a `rebuild.py` deploy and a Hyprland restart, the desktop runs with waybar, rofi and hyprpaper uninstalled or stopped. Wallpaper, bar, launcher, audio panel, Bluetooth panel, power panel and lock screen all work as CAP-1 to CAP-8 describe.

## Assumptions

- The Quickshell config lives in `quickshell/` in this repo, is deployed to `~/.config/quickshell` by `rebuild.py`, and is started through Hyprland `exec-once`.
- Success signal drafted by the assistant from the capabilities; not yet confirmed by the user.

## Open Questions

- Should idle auto-lock (hypridle) or lock-on-suspend be in scope? Neither was requested.
- Should the lock have triggers beyond a keybind and the power-panel entry?
- Does the Quickshell version in nixpkgs 25.11 provide the Pipewire, Bluetooth, SessionLock and Hyprland modules needed? Verify before implementation.
- How is the PAM service for the lock screen declared in `configuration.nix`?
- Is the wallpaper a single static image, or selectable or rotating?
- Reuse the current greens and whites (Hyprland borders), or a new palette?
