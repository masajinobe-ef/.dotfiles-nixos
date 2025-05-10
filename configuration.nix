{ config, pkgs, callPackage, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "ru_RU.UTF-8";
  #   LC_IDENTIFICATION = "ru_RU.UTF-8";
  #   LC_MEASUREMENT = "ru_RU.UTF-8";
  #   LC_MONETARY = "ru_RU.UTF-8";
  #   LC_NAME = "ru_RU.UTF-8";
  #   LC_NUMERIC = "ru_RU.UTF-8";
  #   LC_PAPER = "ru_RU.UTF-8";
  #   LC_TELEPHONE = "ru_RU.UTF-8";
  #   LC_TIME = "ru_RU.UTF-8";
  # };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.masa = {
    isNormalUser = true;
    description = "masa";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages list
  environment.systemPackages = with pkgs; [

    # X11
    xorg.xorgserver
    xorg.xinit
    xorg.xset
    xorg.xsetroot
    xorg.xrandr  

    # CLI
    vim
    neovim
    yazi
    imagemagick
    wget
    git
    zsh
    stow
    tmux
    yt-dlp
    ffmpeg
    fastfetch
    btop
    eza
    fzf
    fd
    ripgrep
    curl
    maim
    xdotool
    xclip
    xsel
    jq
    poppler
    p7zip
    unrar
    zip
    unzip
    xdg-user-dirs
    exiftool
    ueberzugpp
    polkit_gnome

    # GUI
    alacritty
    chromium
    mpv
    i3
    i3status
    picom
    lxappearance

    # Utils
    rofi
    dunst
    libnotify
    feh

    # System
    mesa
    acpid
    cronie
    auto-cpufreq
    brightnessctl

    # Fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 33677 80 8080 443 ];
  networking.firewall.allowedUDPPorts = [ 9 ];

  # NixOS version
  system.stateVersion = "25.05";

}
