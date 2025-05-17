{ config, pkgs, lib, inputs, outputs, callPackage, ... }:

{
  # ===================== Hardware Configuration =====================
  imports = [ ./hardware-configuration.nix ];

  # ===================== Nix Package Management =====================
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
};

  # ===================== Boot Configuration =====================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };

    kernelParams = [
      "loglevel=4"
      "mitigations=off"
      "nmi_watchdog=0"
      "amd_pstate=active"
      "cpufreq.default_governor=performance"
    ];
  };

  # ===================== Networking =====================
  networking = {
    hostName = "nixos";
    enableIPv6 = false;

    networkmanager = {
      enable = true;
      insertNameservers = [ "8.8.8.8" "8.8.4.4" ];  # Google DNS
    };

    interfaces.enp42s0 = {
      ipv4.addresses = [{
        address = "192.168.0.200";
        prefixLength = 24;
      }];
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp42s0";
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 33677 80 8080 443 ];
      allowedUDPPorts = [ 9 ];
    };
  };

  # ===================== Regional Settings =====================
  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ===================== Wayland/Sway Configuration =====================
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      waybar
      wofi
      wl-clipboard
      mako
      grim
      slurp
      swaybg 
    ];
};
  
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
  };

  security = {
    pam.services = {
      swaylock = {};
      gdm.enableGnomeKeyring = true;
    };
    polkit.enable = true;
  };
  
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        mesa
        libvdpau
        libva
      ];
    };
  };

environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER="vulkan";
    SWAYSOCK="$XDG_RUNTIME_DIR/sway-ipc.$UID.$(pgrep -x sway).sock";
  };

  # ===================== User Configuration =====================
  users.users.masa = {
    isNormalUser = true;
    description = "masa";
    extraGroups = [ "networkmanager" "wheel" "seat" "audio" "realtime" ];
  };

  # ===================== System Packages =====================
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim wget git neovim alacritty zsh dnsmasq dnscrypt-proxy dnsutils sing-box gnome-keyring gnome-session gnome-shell gnome-control-center

    # File management
    yazi eza fzf fd ripgrep p7zip unrar zip unzip

    # Media handling
    imagemagick exiftool ueberzugpp yt-dlp ffmpeg

    # System monitoring
    fastfetch btop

    # Development tools
    tmux stow ghq tmuxp docker uv gcc clang pnpm zoxide nodejs gnumake

    # Languages
    python313 go rustup

    # Wayland utilities
    wl-clipboard grim slurp

    # Desktop components
    redshift

    # Applications
    mpv
    vlc
    ayugram-desktop
    qbittorrent

    (google-chrome.override {
      commandLineArgs = [
        "--force-device-scale-factor=0.9"
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })

    # System utilities
    acpid xdg-user-dirs xdg-utils qt5.qtwayland

    # Icons
    papirus-icon-theme
  ];

  # ===================== Font Configuration =====================
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];

  # ===================== System Services =====================
  services = {
    openssh = {
      enable = true;
      ports = [ 33677 ];
      settings = {
        AddressFamily = "inet";
        Protocol = 2;
        SyslogFacility = "AUTH";
        LogLevel = "VERBOSE";
        KexAlgorithms = [ "curve25519-sha256" ];
        Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
        Macs = [ "hmac-sha2-512-etm@openssh.com" ];
        PermitRootLogin = "prohibit-password";
        PubkeyAuthentication = true;
        AuthenticationMethods = "publickey";
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

    dbus.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    seatd.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        defaultSession = "sway";
      };
    };
    libinput.enable = true;
    acpid.enable = true;
    fstrim.enable = true;
    pulseaudio.enable = false;
  };

  # ===================== Final System Settings =====================
  system.stateVersion = "24.11";
}
