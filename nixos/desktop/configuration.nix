{ ... }:

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
    ./services.nix
    ./fonts.nix
  ];

  system.stateVersion = "24.11";
}
