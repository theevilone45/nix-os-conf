import argparse
import glob
import os
import subprocess
from getpass import getpass

USER_HOME = os.path.expanduser("~")

LOCAL_CONFIG_PATHS = {
    "nixos": "./nixos/configuration.nix",
    "hyprland": "./hyprland/",
    "waybar": "./waybar/",
    "rofi": "./rofi/",
}

DESTINATION_PATHS = {
    "nixos": "/etc/nixos/configuration.nix",
    "hyprland": f"{USER_HOME}/.config/hypr/.",
    "waybar": f"{USER_HOME}/.config/waybar/.",
    "rofi": f"{USER_HOME}/.config/rofi/.",
}

def apply_nixos_rebuild():
    password = getpass("Enter sudo password: ")
    password_input = password + "\n"
    output = subprocess.run(["sudo", "-S", "cp", "-v", LOCAL_CONFIG_PATHS["nixos"], DESTINATION_PATHS["nixos"]], stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=password_input, encoding="ascii")
    print(output.stdout)
    output = subprocess.run(["sudo", "-S", "nixos-rebuild", "switch"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=password_input, encoding="ascii")
    print(output.stdout)

def apply_hyprland_rebuild():
    files = glob.glob(f"{LOCAL_CONFIG_PATHS['hyprland']}*")
    output = subprocess.run(["cp", "-v"] + files + [DESTINATION_PATHS["hyprland"]], capture_output=True, text=True)
    print(output.stdout)

def apply_waybar_rebuild():
    files = glob.glob(f"{LOCAL_CONFIG_PATHS['waybar']}*")
    output = subprocess.run(["cp", "-v"] + files + [DESTINATION_PATHS["waybar"]], capture_output=True, text=True)
    print(output.stdout)

def apply_rofi_rebuild():
    files = glob.glob(f"{LOCAL_CONFIG_PATHS['rofi']}*")
    output = subprocess.run(["cp", "-v"] + files + [DESTINATION_PATHS["rofi"]], capture_output=True, text=True)
    print(output.stdout)

APPLY_COMMANDS = {
    "nixos": apply_nixos_rebuild,
    "hyprland": apply_hyprland_rebuild,
    "waybar": apply_waybar_rebuild,
    "rofi": apply_rofi_rebuild,
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
    parser.add_argument("-a", "--all", action="store_true", default=False, help="Rebuild all configurations")
    parser.add_argument("-d", "--diff", action="store_true", default=False, help="Only show differences instead of rebuilding")
    return parser.parse_args()

def print_diff(component):
    print(f"Showing differences for {component} configuration...")
    output = subprocess.run(
        ["diff", "-r", "-u", LOCAL_CONFIG_PATHS[component], DESTINATION_PATHS[component]],
        capture_output=True,
        text=True
    )
    print(output.stdout if output.stdout else "No differences found.")
    return True if output.stdout else False


def dispach_action(args):
    for component in LOCAL_CONFIG_PATHS.keys():
        if getattr(args, component):
            result = print_diff(component)
            if not result or args.diff:
                continue
            print(f"Rebuilding {component} configuration...")
            APPLY_COMMANDS[component]()

  
def main():
    args = parse_arguments()

    if args.all:
        args.nixos = True
        args.hyprland = True
        args.waybar = True
        args.rofi = True

    dispach_action(args)


if __name__ == "__main__":
    main()