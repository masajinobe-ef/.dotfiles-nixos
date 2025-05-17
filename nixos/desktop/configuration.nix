{
  imports = [
    ./hardware-configuration.nix
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./wayland-sway.nix
    ./users.nix
    ./packages.nix
    ./fonts.nix
    ./services.nix
  ];

  system.stateVersion = "24.11";
}
