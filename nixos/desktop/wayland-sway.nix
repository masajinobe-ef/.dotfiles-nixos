{ pkgs }:

{
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_RENDERER = "vulkan";
    SUDO_PROMPT = "ENTER YOUR PASSWORD: ";
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    BROWSER = "google-chrome";
    UV_LINK_MODE = "copy";
    COMPOSE_BAKE = "true";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      waybar
      rofi-wayland
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
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  security = {
    pam.services = {
      swaylock = { };
      gdm.enableGnomeKeyring = true;
    };
    polkit.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa libvdpau libva ];
  };
}
