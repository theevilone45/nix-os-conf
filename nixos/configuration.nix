# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# TODO: divide this file into components

{ config, pkgs, ... }:

{
  imports = [
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

  programs.wireshark.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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

  programs.bash = {
    interactiveShellInit = ''
      eval "$(starship init bash)"
      eval "$(direnv hook bash)"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.sessionVariables = {
    STARSHIP_CONFIG = "/home/marcins/.config/starship/starship.toml";
  };

  # Login screen: greetd runs the Quickshell greeter (Greeter.qml) under cage.
  # ./greeter is /etc/nixos/greeter, holding only the files the greeter imports (copied by
  # `rebuild.py -n`); the store copy below lets the greeter user read them. cage -s keeps
  # Ctrl+Alt+Fn VT switching as a TTY fallback. QT_WAYLAND_DISABLE_WINDOWDECORATION hides
  # the Qt client-side title bar/border that cage does not draw over.
  services.greetd =
    let
      greeterShell = pkgs.runCommand "quickshell-greeter" { } ''
        mkdir $out
        cp ${./greeter}/*.qml $out/
        printf 'singleton Theme Theme.qml\nLockContent LockContent.qml\n' > $out/qmldir
      '';
    in
    {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = "${pkgs.coreutils}/bin/env XKB_DEFAULT_LAYOUT=pl QT_WAYLAND_DISABLE_WINDOWDECORATION=1 ${pkgs.cage}/bin/cage -s -- ${pkgs.quickshell}/bin/quickshell -p ${greeterShell}/Greeter.qml";
      };
    };

  # Enable X server (videoDrivers and xkb settings below hang off it)
  services.xserver.enable = true;

  # AMD GPU drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0070", TAG+="uaccess"
  '';

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  # PAM service used by the Quickshell lock screen (quickshell/Lock.qml)
  security.pam.services.quickshell = { };
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "wireshark"
      "dialout"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.caskaydia-cove
    ];
  };

  # services.tailscale.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    zed-editor
    wget
    firefox
    claude-code
    uv
    #p7zip
    inetutils
    qutebrowser
    freecad
    orca-slicer
    mesa-demos
    vulkan-tools
    lm_sensors
    btop
    ripgrep
    vlc
    zathura
    qbittorrent
    furmark
    pipewire
    pulseaudio
    pavucontrol
    blueman
    mpv
    libsForQt5.pulseaudio-qt
    usbutils
    discord-ptb
    yazi
    jq
    starship
    nerdfetch
    unzip
    tcpdump
    radeontop
    universal-ctags
    # Font
    rose-pine-hyprcursor
    # Hyprland related packages
    kitty
    dunst
    quickshell
    hyprcursor
    hyprshot
    hyprpicker
    opentabletdriver
    udiskie
    krita
    yafc-ce
    testdisk
    bibata-cursors
    # tailscale

    (makeDesktopItem {
      name = "yafc-ce";
      desktopName = "YAFC Community Edition";
      comment = "Factorio calculator";
      exec = "Yafc";
      terminal = false;
      categories = [
        "Game"
        "Utility"
      ];
    })
  ];

  programs.nix-ld.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  programs.xwayland.enable = true;

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

  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  # Firewall:
  # - Tailscale itself may establish direct connections.
  # - Factorio 34197/UDP is accessible ONLY through tailscale0.
  # networking.firewall = {
  #   allowedUDPPorts = [
  #     config.services.tailscale.port
  #   ];

  #   interfaces."tailscale0".allowedUDPPorts = [
  #     34197
  #   ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
