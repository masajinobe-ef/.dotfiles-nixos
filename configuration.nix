{ config, pkgs, callPackage, ... }:

{
  ###############
  # System Configuration
  ###############
  system.stateVersion = "25.05";
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
    allowReboot = false;
  };

  ###############
  # Hardware Settings
  ###############
  imports = [ ./hardware-configuration.nix ];

  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


  ###############
  # Kernel Settings
  ###############
  boot = {
     kernelParams = [
        "loglevel=4"
        "mitigations=off"
        "intel_pstate=disable"
        "usbcore.autosuspend=1"
        "intel_iommu=off"
        "nmi_watchdog=0"
        "i915.enable_fbc=1"
        "intel_idle.max_cstate=5"
        "processor.max_cstate=5"
        "zswap.enabled=1"
        "zswap.compressor=lz4"
        "zswap.max_pool_percent=20"
        "zswap.zpool=zsmalloc"
      ];

    # Blacklist problematic modules
    blacklistedKernelModules = [
      "ssb" "mmc_core" "b43" "brcmsmac" "brcmutil"
      "cordic" "mac80211" "bcma" "iTCO_wdt" "iTCO_vendor_support"
    ];

    # Load wireless module
    kernelModules = [ "wl" ];

    # HID Apple configuration
    extraModprobeConfig = ''
      options hid_apple fnmode=2 iso_layout=1
    '';

    # Initrd modules for vfat support
    initrd.kernelModules = [ "vfat" ];
  };

  # Kernel parameters

  ###############
  # Networking
  ###############
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 33677 80 8080 443 ];
      allowedUDPPorts = [ 9 ];
    };
  };

  ###############
  # Localization
  ###############
  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
    };
  };

  services.xserver = {

  xkb = {
    layout = "us";
    variant = "";
    options = "grp:caps_toggle";
  };

  # Touchpad configuration
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "buttonareas";
        accelProfile = "adaptive";
        scrollMethod = "two-finger";
        disableWhileTyping = true;
        additionalOptions = ''
          Option "PalmDetection" "true"
          Option "ButtonAreas" "50% 0 100% 50% 0 0 50% 0"
          Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
        '';
      };

      # Mouse configuration
      mouse = {
        naturalScrolling = false;
        accelProfile = "flat";
        additionalOptions = ''
          Option "TransformationMatrix" "1 0 0 0 1 0 0 0 2.0"
        '';
      };
    };

    inputClassSections = [
      ''
        Identifier "pointer"
        MatchIsPointer "on"
        Driver "libinput"
        Option "AccelSpeed" "0"
      ''
    ];
  };

  ###############
  # User Management
  ###############
  users.users.masa = {
    isNormalUser = true;
    description = "masa";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  ###############
  # Services Configuration
  ###############
  services = {
    # SSH Service
    openssh = {
      enable = true;
      settings = {
        AddressFamily = "inet";
        Port = 33677;
        Protocol = 2;
        SyslogFacility = "AUTH";
        LogLevel = "VERBOSE";
        KexAlgorithms = [ "curve25519-sha256" ];
        Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
        MACs = [ "hmac-sha2-512-etm@openssh.com" ];
        PermitRootLogin = "prohibit-password";
        PubkeyAuthentication = true;
        AuthenticationMethods = [ "publickey" ];
        PasswordAuthentication = false;
        PermitEmptyPasswords = false;
        UsePAM = true;
        LoginGraceTime = 60;
        MaxAuthTries = 3;
        ClientAliveInterval = 600;
        ClientAliveCountMax = 2;
        AllowTcpForwarding = false;
        X11Forwarding = false;
        PermitTunnel = false;
        Subsystem = "sftp internal-sftp";
      };
    };

    # Power Management
    acpid.enable = true;

    # Scheduled Tasks
    cronie.enable = true;

    # CPU Frequency Scaling
    auto-cpufreq.enable = true;

    # Filesystem Trim
    fstrim.enable = true;

    # Privilege Management
    gnome.polkit.enable = true;
  };

  ###############
  # Packages & Environment
  ###############
  environment.systemPackages = with pkgs; [
    # X11 Components
    xorg.xorgserver xorg.xinit xorg.xset xorg.xsetroot xorg.xrandr

    # CLI Tools
    vim neovim yazi imagemagick wget git zsh stow tmux yt-dlp
    ffmpeg fastfetch btop eza fzf fd ripgrep curl maim xdotool
    xclip xsel jq poppler p7zip unrar zip unzip xdg-user-dirs
    exiftool ueberzugpp

    # GUI Applications
    alacritty chromium mpv i3 i3status picom lxappearance

    # Utilities
    rofi dunst libnotify feh

    # System Tools
    mesa acpid cronie auto-cpufreq brightnessctl

    # Fonts
    nerd-fonts.jetbrains-mono noto-fonts noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  ###############
  # Nix Settings
  ###############
  nix = {
    # Allow unfree packages
    pkgs.config.allowUnfree = true;

    # Garbage Collection
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
  };
}
