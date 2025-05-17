{ pkgs }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (nerd-fonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "JetBrains Mono Nerd Font" ];
  };
}
