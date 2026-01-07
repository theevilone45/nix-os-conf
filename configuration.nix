# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.blacklistedKernelModules = [
    "rtw89_8922ae"
  ];
  
  # Kernel parameters for better Bluetooth performance
  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
    "bluetooth.disable_ertm=1"
    "amd_pstate=active"
  ];

  powerManagement.cpuFreqGovernor = "schedutil";

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display Manager - needed for graphical login
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable X server (needed for display manager)
  services.xserver.enable = true;

  # AMD GPU drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.pipewire.extraConfig.pipewire."10-latency.conf" = {
    "context.properties" = {
      "default.clock.quantum" = 256;
      "default.clock.min-quantum" = 256;
      "default.clock.max-quantum" = 256;
    };
  };

  services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marcins = {
    isNormalUser = true;
    description = "marcins";
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  nixpkgs.config.allowUnfree = true;

  # fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      font-awesome_6
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    vscode
    firefox
    freecad
    orca-slicer
    mesa-demos
    vulkan-tools
    lm_sensors
    btop
    pipewire
    pulseaudio
    pavucontrol
    blueman
    mpv
    libsForQt5.pulseaudio-qt
    usbutils
    discord-ptb
    yazi
    # Hyprland related packages
    kitty
    waybar
    dunst
    rofi
    hyprpaper
    hyprcursor
    rose-pine-hyprcursor
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = true;
  services.udev.packages = with pkgs; [ game-devices-udev-rules ];
  
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
