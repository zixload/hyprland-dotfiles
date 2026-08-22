#!/usr/bin/env bash
# install.sh — sets up this Hyprland rice on a fresh Arch Linux install.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

if ! command -v pacman >/dev/null 2>&1; then
    echo "This installer targets Arch Linux (pacman not found). Aborting." >&2
    exit 1
fi

echo "==> Installing official repo packages"
sudo pacman -S --needed --noconfirm \
    git base-devel \
    hyprland hyprlock sddm waybar rofi dunst kitty thunar wlogout \
    grim slurp cliphist wl-clipboard playerctl wireplumber \
    networkmanager network-manager-applet polkit-kde-agent \
    xdg-desktop-portal-hyprland \
    jq nvtop awww quickshell vivaldi pavucontrol

echo "==> Enabling system services"
sudo systemctl enable --now NetworkManager
sudo systemctl enable sddm

echo "==> Installing AUR packages"
if ! command -v paru >/dev/null 2>&1; then
    echo "paru not found — building it from AUR first"
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi
paru -S --needed --noconfirm wlogout

echo "==> Optional AUR extras (fonts used by the theme, Spotify)"
paru -S --needed --noconfirm ttf-iosevka ttf-cascadia-code-nerd-font-mono spotify || \
    echo "Optional extras failed or were skipped — not fatal, continuing."

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  backing up existing $dest -> $dest.bak-$TIMESTAMP"
        mv "$dest" "$dest.bak-$TIMESTAMP"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi
    ln -s "$src" "$dest"
    echo "  linked $dest"
}

echo "==> Symlinking config into $CONFIG_DIR"
link "$DOTFILES_DIR/hypr"                          "$CONFIG_DIR/hypr"
link "$DOTFILES_DIR/waybar"                        "$CONFIG_DIR/waybar"
link "$DOTFILES_DIR/rofi"                          "$CONFIG_DIR/rofi"
link "$DOTFILES_DIR/kitty"                         "$CONFIG_DIR/kitty"
link "$DOTFILES_DIR/wlogout"                       "$CONFIG_DIR/wlogout"
link "$DOTFILES_DIR/quickshell/hyprquickpaper"     "$CONFIG_DIR/quickshell/hyprquickpaper"

echo "==> Copying wallpapers to ~/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Wallpapers"
cp -n "$DOTFILES_DIR"/wallpapers/* "$HOME/Pictures/Wallpapers/"

chmod +x "$CONFIG_DIR"/hypr/scripts/*.sh "$CONFIG_DIR"/waybar/scripts/*.sh 2>/dev/null || true

cat <<'EOF'

==> Done.

Next steps:
  1. Reboot (or start sddm now: sudo systemctl start sddm). SDDM was enabled but
     not started, so it won't yank you out of your current session.
  2. At the login screen, pick "Hyprland" as your session.
  3. First launch will autostart waybar, dunst, nm-applet, cliphist, awww (wallpaper
     daemon) and set the wallpaper to wallpapers/w3.jpg. Change it any time with:
       awww img ~/Pictures/Wallpapers/<file>
  4. See README.md for the full keybind list.

Notes:
  - kb_layout is set to "fr" (AZERTY) in hypr/hyprland.lua. If you use a different
    layout, change it there — the workspace keybinds are bound by physical keycode
    (code:10-19) so they work regardless of the layout's symbol mapping.
  - The GPU widget in waybar (waybar/scripts/gpu_usage.sh) requires an NVIDIA GPU
    visible to nvtop; on other hardware, edit or remove the "custom/gpu" module in
    waybar/config.jsonc.
EOF
