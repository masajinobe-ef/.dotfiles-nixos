# .dotfiles

#### Keymaps

|       OS       |        [Arch Linux](https://archlinux.org/)         |
| :------------: | :-------------------------------------------------: |
|   AUR Helper   |         [yay](https://github.com/Jguer/yay)         |
|     Shell      |               [zsh](https://ohmyz.sh)               |
| Window Manager |           [i3](https://github.com/i3/i3)            |
|   Compositor   |       [picom](https://github.com/yshui/picom)       |
|      Menu      |     [rofi](https://github.com/davatorium/rofi)      |
|    Terminal    | [alacritty](https://github.com/alacritty/alacritty) |
|  File Manager  |          [yazi](https://yazi-rs.github.io)          |
|    Browser     |  [thorium](https://github.com/Alex313031/thorium)   |
|  Text Editor   |             [neovim](https://neovim.io)             |

---

### Installation

#### AUR Helper

The initial installation of [yay](https://github.com/Jguer/yay).

```sh
$ sudo pacman -Syu --needed neovim reflector git base-devel
$ git clone https://aur.archlinux.org/yay.git
$ cd yay && makepkg -si
$ cd ~ && rm -rf yay
```

#### Clone repository

Clone the **repository** and update submodules:

```sh
$ git clone --depth=1 --recurse-submodules https://github.com/masajinobe-ef/.dotfiles
$ cd .dotfiles && git submodule update --remote --merge
```

---

#### Installing packages

> Assuming your **AUR Helper** is [yay](https://github.com/Jguer/yay), run:

```sh
yay -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xorg-xset \
    i3-wm i3status rofi thorium-browser-bin alacritty zsh dunst libnotify picom feh redshift \
    vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader \
    lib32-vulkan-icd-loader mesa mesa-utils mesa-vdpau \
    libva-mesa-driver lib32-mesa networkmanager nm-connection-editor \
    sof-firmware bluez bluez-utils acpid cronie udisks2 \
    xdg-user-dirs yazi perl-image-exiftool ueberzugpp imagemagick \
    polkit-gnome \
    lxappearance-gtk3 neovim mpv mpd mpdris2 ncmpcpp mpc \
    tmux tmuxp ghq rainfrog git stow yt-dlp \
    ffmpeg fastfetch btop eza fzf fd ripgrep \
    curl wget maim xdotool xclip \
    xsel reflector jq poppler \
    p7zip unrar zip unzip ttf-jetbrains-mono-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code-nerd \
    papirus-icon-theme
```

#### Daemons

Enable and start necessary **services**:

```sh
$ sudo systemctl enable acpid.service --now
$ sudo systemctl enable NetworkManager.service --now
$ sudo systemctl enable bluetooth.service --now
$ sudo systemctl enable sshd.service --now
$ sudo systemctl enable cronie.service --now

$ systemctl --user enable mpd.service --now

$ sudo systemctl enable fstrim.timer
```

Install **Oh My Zsh**:

```sh
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Consider installing the following plugins for Zsh:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)

Install **commitizen**:

```sh
$ npm install -g commitizen commitizen-cli cz-conventional-changelog cz-customizable
```

Install **uv**:

```sh
$ curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

#### Setting-up

Add **languages** to your system:

```sh
$ sudo nvim /etc/locale.gen

ru_RU.UTF-8 UTF-8

$ sudo locale-gen
```

Set the **keyboard** layout in X11:

```sh
$ sudo localectl --no-convert set-x11-keymap us,ru pc105+inet qwerty grp:caps_toggle
```

Configure the **mouse** settings:

```sh
$ sudo nvim /etc/X11/xorg.conf.d/30-pointer.conf

Section "InputClass"
    Identifier "pointer"
    Driver "libinput"
    MatchIsPointer "on"
    Option "NaturalScrolling" "false"
    Option "AccelProfile" "flat"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 2"
EndSection
```
