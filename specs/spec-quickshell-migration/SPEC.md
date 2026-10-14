---
id: SPEC-quickshell-migration
companions: []
sources: []
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# Quickshell Desktop Shell Migration

## Why

A vision and consolidation effort for a single-user NixOS/Hyprland desktop (3440×1440 ultrawide). The shell was split across waybar, three rofi-dmenu shell scripts, rofi's launcher, and hyprpaper. Each had its own config, theme and refresh hack (`pkill -RTMIN+8 waybar`), and the panels were text menus without sliders or per-app control. Quickshell gives one declaratively styled QML shell for bar, panels, launcher, wallpaper, lock screen and boot login screen, deployable through the existing `rebuild.py` workflow. Boot is a few seconds on NVMe, so the user wants a password at login but no idle auto-lock or lock-on-suspend, and wants the apps used daily one click away.

## Capabilities

- **CAP-1**
  - **intent:** The shell paints the desktop wallpaper on DP-1, replacing hyprpaper.
  - **success:** With hyprpaper not installed, `~/Wallpapers/Unkown.jpg` shows on DP-1 after login. Changing the path in `quickshell/Theme.qml` and saving changes the image without restarting Hyprland.
- **CAP-2**
  - **intent:** The user can lock the session and unlock it with their password; nothing is visible or interactive until authentication.
  - **success:** A wrong password stays locked, the correct one unlocks, and windows are neither visible nor clickable while locked. SUPER+L and the power panel both lock.
- **CAP-3**
  - **intent:** The user can shut down, reboot or lock from one power panel.
  - **success:** Each entry performs its action.
- **CAP-4**
  - **intent:** The user can see and set output volume and mute, choose the default output, and adjust per-application stream volume.
  - **success:** Changing the default output moves existing streams to it. Volume keys and the panel stay in sync with no signal hack, and the bar shows the live volume.
- **CAP-5**
  - **intent:** The user can see paired Bluetooth devices, connect or disconnect them, and switch the audio profile of a connected device.
  - **success:** After connecting a headset its profiles appear within about 2 s. Selecting one applies it, and the active one is marked.
- **CAP-6**
  - **intent:** The user can read time and date at a glance and open a month calendar.
  - **success:** The clock shows the current time. The calendar shows the current month with today highlighted.
- **CAP-7**
  - **intent:** A minimal bar shows workspaces and the clock and hosts the entry points to the panels.
  - **success:** Workspace state is reflected live, and the calendar, audio, Bluetooth and power panels each open from the bar, one at a time.
- **CAP-8**
  - **intent:** The user can search and launch installed applications, replacing rofi drun.
  - **success:** SUPER+R opens the launcher, typing filters installed apps, Enter launches the selection (terminal apps in kitty), and Esc closes it.
- **CAP-9**
  - **intent:** The screen shown at boot is the same as the lock screen, and unlocking it logs the user into Hyprland.
  - **success:** After boot the login screen looks identical to the lock screen, with no username field; it logs in the fixed user marcins. A wrong password stays on it, the correct one starts the Hyprland session on DP-1.
- **CAP-10**
  - **intent:** Pinned application icons on the bar launch the user's favourite apps.
  - **success:** Clicking the qutebrowser, steam and zeditor icons starts each app. Editing the favourites file and redeploying changes the icons.

## Constraints

- Edit only repo files and deploy through `rebuild.py` with a Quickshell component (`-q`); never edit `~/.config/` directly.
- Never run `nixos-rebuild`: package and service changes go in `nixos/configuration.nix` and the user applies them.
- NixOS 25.11 channel: Quickshell comes from that channel (0.2.1).
- Single target: Hyprland on DP-1 at 3440×1440@144. No multi-monitor or laptop support.
- The session lock must use `ext-session-lock`, so a crashed lock surface cannot expose the session. Authentication goes through the `quickshell` PAM service declared in `configuration.nix`.
- Audio goes through PipeWire/WirePlumber and Bluetooth through BlueZ, using native Quickshell services; no new shell-script backends. The one exception is Bluetooth audio profile listing and switching, which calls `pactl` because Quickshell exposes no PipeWire card profiles.
- The boot login uses greetd, with a Quickshell greeter talking to it through `Quickshell.Services.Greetd` (in 0.2.1). The greeter shares its QML with the lock screen so the two cannot diverge visually. SDDM is removed.
- The favourites list lives in its own file, not in `Theme.qml`, and is a fixed list changed by editing the repo and redeploying.
- Lock happens only on request (SUPER+L, power panel). No idle or suspend trigger exists.
- `rebuild.py` copies files without recursing, so `quickshell/` stays flat, and every QML type must be listed in `quickshell/qmldir`.

## Non-goals

- No widget kit or general theming framework.
- No notifications, tray or OSD; dunst stays.
- No Bluetooth scan or pairing; that stays in blueman.
- No microphone controls in the audio panel.
- Waybar's CPU, temperature, RAM, network and window-title modules are dropped on purpose.
- No multi-monitor support.
- No idle auto-lock (hypridle) and no lock-on-suspend.
- No favourites section in the launcher; the launcher stays plain search.
- No running-state indicator or focus-existing-window behaviour on favourite icons.
- No autologin; the user types a password at boot.

## Success signal

The desktop runs on Quickshell alone, with waybar, rofi, hyprpaper and SDDM gone from the repo and the system packages. Boot login, wallpaper, bar, favourites, launcher, audio panel, Bluetooth panel, power panel and lock screen all work as CAP-1 to CAP-10 describe.

## Assumptions

- The greeter needs a minimal Wayland compositor to run Quickshell; which one is left to architecture.
- A broken greeter must not leave the machine without a login path, so a TTY fallback is kept.
- Favourites launch through desktop entries, with icons from the icon theme.
