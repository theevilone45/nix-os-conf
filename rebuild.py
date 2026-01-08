import argparse
import glob
from importlib.resources import files
import os
import stat
import subprocess
from getpass import getpass

USER_HOME = os.path.expanduser("~")

LOCAL_CONFIG_PATHS = {
    "nixos": "./nixos/configuration.nix",
    "hyprland": "./hyprland/",
    "waybar": "./waybar/",
    "rofi": "./rofi/",
    "kitty": "./kitty/",
    "starship": "./starship/starship.toml",
}

DESTINATION_PATHS = {
    "nixos": "/etc/nixos/configuration.nix",
    "hyprland": f"{USER_HOME}/.config/hypr/.",
    "waybar": f"{USER_HOME}/.config/waybar/.",
    "rofi": f"{USER_HOME}/.config/rofi/.",
    "kitty": f"{USER_HOME}/.config/kitty/.",
    "starship": f"{USER_HOME}/.config/starship/starship.toml",
}

def apply_nixos_rebuild():
    password = getpass("Enter sudo password: ")
    password_input = password + "\n"
    output = subprocess.run(["sudo", "-S", "cp", "-pv", LOCAL_CONFIG_PATHS["nixos"], DESTINATION_PATHS["nixos"]], stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=password_input, encoding="utf-8")
    print(output.stdout)
    output = subprocess.run(["sudo", "-S", "nixos-rebuild", "switch"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=password_input, encoding="utf-8")
    print(output.stdout)

def apply_standard_rebuild(component):
    files = glob.glob(f"{LOCAL_CONFIG_PATHS[component]}*")
    output = subprocess.run(["cp", "-pv"] + files + [DESTINATION_PATHS[component]], capture_output=True, text=True)
    print(output.stdout)

def apply_hyprland_rebuild():
    apply_standard_rebuild("hyprland")

def apply_waybar_rebuild():
    apply_standard_rebuild("waybar")

def apply_rofi_rebuild():
    apply_standard_rebuild("rofi")


def apply_kitty_rebuild():
    apply_standard_rebuild("kitty")

def apply_starship_rebuild():
    apply_standard_rebuild("starship")

APPLY_COMMANDS = {
    "nixos": apply_nixos_rebuild,
    "hyprland": apply_hyprland_rebuild,
    "waybar": apply_waybar_rebuild,
    "rofi": apply_rofi_rebuild,
    "kitty": apply_kitty_rebuild,
    "starship": apply_starship_rebuild,
}

def validate_configuration():
    if LOCAL_CONFIG_PATHS.keys() != DESTINATION_PATHS.keys() != APPLY_COMMANDS.keys():
        raise ValueError("Configuration keys do not match.")

def parse_arguments():
    parser = argparse.ArgumentParser(description="A script that can be used to rebuild NixOs configuration as well as Hyprland configuration files.")
    parser.add_argument("-n", "--nixos", action="store_true", default=False, help="Rebuild NixOs configuration, this option require sudo privileges")
    parser.add_argument("-p", "--hyprland", action="store_true", default=False, help="Rebuild Hyprland configuration files")
    parser.add_argument("-w", "--waybar", action="store_true", default=False, help="Rebuild Waybar configuration files")
    parser.add_argument("-r", "--rofi", action="store_true", default=False, help="Rebuild Rofi configuration files")
    parser.add_argument("-k", "--kitty", action="store_true", default=False, help="Rebuild Kitty configuration files")
    parser.add_argument("-s", "--starship", action="store_true", default=False, help="Rebuild Starship configuration files")
    parser.add_argument("-a", "--all", action="store_true", default=False, help="Rebuild all configurations")
    parser.add_argument("-d", "--diff", action="store_true", default=False, help="Only show differences instead of rebuilding")
    return parser.parse_args()

def get_permission_string(mode):
    """Convert file mode to rwx permission string."""
    perms = []
    for who in ["USR", "GRP", "OTH"]:
        for what in ["R", "W", "X"]:
            flag = getattr(stat, f"S_I{what}{who}")
            perms.append(what.lower() if mode & flag else "-")
    return "".join(perms)

def compare_permissions(local_path, dest_path):
    """Compare file permissions between local and destination paths."""
    perm_diffs = []
    
    if os.path.isdir(local_path):
        for filename in os.listdir(local_path):
            local_file = os.path.join(local_path, filename)
            dest_file = os.path.join(dest_path.rstrip('.'), filename)
            if os.path.isfile(local_file) and os.path.exists(dest_file):
                local_mode = os.stat(local_file).st_mode
                dest_mode = os.stat(dest_file).st_mode
                if local_mode != dest_mode:
                    perm_diffs.append(
                        f"  {filename}: {get_permission_string(dest_mode)} -> {get_permission_string(local_mode)}"
                    )
    else:
        if os.path.exists(dest_path):
            local_mode = os.stat(local_path).st_mode
            dest_mode = os.stat(dest_path).st_mode
            if local_mode != dest_mode:
                perm_diffs.append(
                    f"  {os.path.basename(local_path)}: {get_permission_string(dest_mode)} -> {get_permission_string(local_mode)}"
                )
    
    return perm_diffs

def check_diff(component):
    print(f"Showing differences for {component} configuration...")
    has_diff = False
    
    # Content diff
    output = subprocess.run(
        ["diff", "-r", "-u", DESTINATION_PATHS[component], LOCAL_CONFIG_PATHS[component]],
        capture_output=True,
        text=True
    )
    if output.stdout:
        print(output.stdout)
        has_diff = True
    
    # Permission diff
    perm_diffs = compare_permissions(LOCAL_CONFIG_PATHS[component], DESTINATION_PATHS[component])
    if perm_diffs:
        print("Permission differences:")
        for diff in perm_diffs:
            print(diff)
        has_diff = True
    
    if not has_diff:
        print("No differences found.")
    
    return has_diff


def dispach_action(args):
    for component in LOCAL_CONFIG_PATHS.keys():
        if getattr(args, component):
            result = check_diff(component)
            if not result or args.diff:
                continue
            confirm = input(f"Do you want to apply the changes to {component} configuration? (Y/n): ")
            print("confirm: ", confirm)
            if confirm.lower() != 'y' and confirm != '':
                print(f"Elo xD")
                continue
            print(f"Rebuilding {component} configuration...")
            APPLY_COMMANDS[component]()

  
def main():
    validate_configuration()
    args = parse_arguments()

    if args.all:
        args.nixos = True
        args.hyprland = True
        args.waybar = True
        args.rofi = True
        args.kitty = True
        args.starship = True

    dispach_action(args)


if __name__ == "__main__":
    main()