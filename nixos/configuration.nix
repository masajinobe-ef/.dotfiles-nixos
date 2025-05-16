{ config, pkgs, lib, inputs, outputs, callPackage, ... }:

{
  # ===================== Hardware Configuration =====================
  imports = [ ./hardware-configuration.nix ];  # Include generated hardware specs

  # ===================== Nix Package Management =====================
  nixpkgs.config.allowUnfree = true;  # Allow proprietary packages

  nix = {
    # Automatic garbage collection settings
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Disk space management
    extraOptions = ''
      min-free = ${toString (500 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # ===================== Boot Configuration =====================
  boot = {
    # UEFI boot configuration
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Hardware compatibility
    blacklistedKernelModules = [
      "ssb" "mmc_core" "b43" "brcmsmac" "brcmutil"
      "cordic" "mac80211" "bcma" "iTCO_wdt" "iTCO_vendor_support"
    ];

    # Hardware-specific kernel modules
    initrd.kernelModules = [ "vfat" "i915" ];

    # Kernel module parameters
    extraModprobeConfig = ''
      options hid_apple fnmode=2 iso_layout=1
      options usbcore autosuspend=1
      options i915 enable_fbc=1
    '';

    # Performance-related kernel parameters
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
      "zswap.compressor=lzo"
      "zswap.max_pool_percent=20"
      "zswap.zpool=zsmalloc"
      "rootfstype=ext4"
    ];
  };

  # ===================== Networking =====================
  networking = {
    hostName = "nixos";
    enableIPv6 = false;

    # NetworkManager configuration
    networkmanager = {
      enable = true;
      dns = "none";
    };

    interfaces.wlp2s0 = {
      ipv4.addresses = [{
        address = "192.168.0.201";
        prefixLength = 24;
      }];
    };
    
    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlp2s0";
    };

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 33677 80 8080 443 ];
      allowedUDPPorts = [ 9 ];
    };
  };

  # DNS configuration
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      server_names = [ "scaleway-fr" "google" ];
      listen_addresses = [ "127.0.0.1:53000" "[::1]:53000" ];
      cache = true;
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      server = [ "::1#53000" "127.0.0.1#53000" ];
      listen-address = [ "::1" "127.0.0.1" ];
      conf-file = "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf";
      dnssec = true;
    };
  };

  # resolv.conf configuration
  environment.etc."resolv.conf" = {
    text = ''
      nameserver ::1
      nameserver 127.0.0.1
      options edns0 single-request-reopen
    '';
    mode = "0444"; # Make immutable
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

  # ===================== Desktop Environment =====================
  services.xserver = {
    enable = true;

    # Keyboard layout configuration
    xkb = {
      layout = "us,ru";
      options = "grp:caps_toggle";
    };

    # Window Manager configuration
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status ];
    };

    desktopManager.xterm.enable = false;
  };

  services.displayManager.defaultSession = "none+i3";

  # ===================== User Configuration =====================
  users.users.masa = {
    isNormalUser = true;
    description = "masa";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # ===================== System Packages =====================
  environment = {
    pathsToLink = [ "/libexec" ];

    systemPackages = with pkgs; [
      # Core utilities
      vim wget git neovim alacritty zsh dnsmasq dnscrypt-proxy dnsutils sing-box

      # File management
      yazi eza fzf fd ripgrep p7zip unrar zip unzip

      # Media handling
      imagemagick exiftool ueberzugpp yt-dlp ffmpeg

      # System monitoring
      fastfetch btop

      # Development tools
      tmux stow ghq tmuxp python313 docker uv gcc clang pnpm zoxide

      # X11 utilities
      maim xdotool xclip xsel lxappearance

      # Desktop components
      rofi dunst libnotify feh picom redshift

      # Applications
      (google-chrome.override {
        commandLineArgs = [
          "--force-device-scale-factor=0.9"
          "--wm-window-animations-disabled"
          "--animation-duration-scale=0"
        ];
      })
      mpv telegram-desktop ayugram-desktop vlc qbittorrent

      # Hardware support
      mesa libva libva-utils libvdpau libvdpau-va-gl

      # System utilities
      acpid auto-cpufreq brightnessctl xdg-user-dirs
    ];
  };

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

    acpid.enable = true;
    auto-cpufreq.enable = true;
    fstrim.enable = true;
    resolved.enable = false;
  };

  # Service dependencies
  systemd.services.dnsmasq.after = [ "dnscrypt-proxy2.service" ];

  # ===================== Final System Settings =====================
  system.stateVersion = "24.11";  # Maintain compatibility with future updates
}
