{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  ####################################
  ##  Boot Configuration
  ####################################
  boot = {
    # GRUB Setup
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
        configurationLimit = 10;
        extraConfig = ''
          GRUB_DEFAULT=0
          GRUB_TIMEOUT=2
          GRUB_DISTRIBUTOR="Arch"
          GRUB_PRELOAD_MODULES="password_pbkdf2 ext4 part_gpt part_msdos"
          GRUB_TIMEOUT_STYLE=menu
          GRUB_TERMINAL_INPUT=console
          GRUB_GFXMODE=auto
          GRUB_GFXPAYLOAD_LINUX=keep
          GRUB_DISABLE_RECOVERY=true
          GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 mitigations=off intel_pstate=disable usbcore.autosuspend=1 intel_iommu=off nmi_watchdog=0 i915.enable_fbc=1 intel_idle.max_cstate=5 processor.max_cstate=5 zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20 zswap.zpool=zsmalloc rootfstype=ext4"
          GRUB_CMDLINE_LINUX=""
        '';
      };
      efi.canTouchEfiVariables = true;
    };

    # Kernel Modules
    blacklistedKernelModules = [
      "ssb" "mmc_core" "b43" "brcmsmac" "brcmutil" "cordic"
      "mac80211" "bcma" "iTCO_wdt" "iTCO_vendor_support"
    ];

    initrd.kernelModules = [ "vfat" "zram" ];
    extraModprobeConfig = "options hid_apple fnmode=2 iso_layout=1";
  };

  ####################################
  ##  Network Configuration
  ####################################
  networking = {
    hostName = "nixos-mac";
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:wlan0" ];
      ethernet.macAddress = "preserve";
      wifi.macAddress = "preserve";
    };
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
  boot.kernelParams = [ "ipv6.disable=1" ];

  ####################################
  ##  SSH Configuration
  ####################################
  services.openssh = {
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

  ####################################
  ##  ZRAM Configuration
  ####################################
  systemd.services.zram-setup = {
    description = "ZRAM Configuration";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.zram-generator}/bin/zram-generator";
    };
  };
  environment.etc."systemd/zram-generator.conf".text = ''
    [zram0]
    zram-size = 4096
    compression-algorithm = lz4
    swap-priority = 100
  '';

  ####################################
  ##  Hardware Configuration
  ####################################
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl ];
    };
    bluetooth.enable = false;
  };

  ####################################
  ##  System Services
  ####################################
  services = {
    acpid.enable = true;
    cron.enable = true;
    auto-cpufreq.enable = true;
    fstrim.enable = true;
    printing.enable = true;
    gnome.polkit.enable = true;
    xserver = {
      enable = true;
      layout = "us,ru";
      xkbOptions = "grp:caps_toggle";
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "buttonareas";
          scrollMethod = "twofinger";
          disableWhileTyping = true;
        };
        mouse.naturalScrolling = false;
      };
      windowManager.i3.enable = true;
      videoDrivers = [ "intel" ];
    };
  };

  ####################################
  ##  User Environment
  ####################################
  users.users.masa = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  environment.systemPackages = with pkgs; [
    # X11
    xorg.xrandr
    xorg.xsetroot
    xorg.xset
    xorg.xorgserver
    xorg.xinit

    # System
    alacritty
    zsh
    chromium
    yazi
    imagemagick
    neovim
    mpv
    i3
    i3status
    rofi
    dunst
    libnotify
    feh
    picom

    # CLI
    tmux
    git
    yt-dlp
    ffmpeg
    fastfetch
    btop
    eza
    fzf
    fd
    ripgrep
    curl
    wget
    maim
    xdotool
    xclip
    xsel
    reflector
    jq
    poppler

    # Drivers and Utils
    mesa
    mesa-demos
    vaapiIntel
    libvdpau-va-gl
    acpid
    cronie
    auto-cpufreq
    brightnessctl
    nm-connection-editor

    # File Manager
    xdg-user-dirs lxappearance
    ffmpegthumbnailer exiftool
    ueberzugpp polkit_gnome

    # Archive
    p7zip unrar zip unzip

    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" "CascadiaCode" ]; })
    noto-fonts noto-fonts-emoji noto-fonts-cjk
    papirus-icon-theme
  ];

  ####################################
  ##  System Optimizations
  ####################################
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.auto-optimise-store = true;
  };
  powerManagement.enable = true;

  ####################################
  ##  Final System Settings
  ####################################
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";
  system.stateVersion = "24.11";
}
