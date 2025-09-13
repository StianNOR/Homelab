#!/bin/bash

# Detect Linux distro name from /etc/os-release
get_distro() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "$NAME"
  else
    uname -s
  fi
}

# Detect Desktop environment (lowercase)
get_desktop_env() {
  local de=${XDG_CURRENT_DESKTOP,,}
  if [[ -z "$de" ]]; then
    de=${DESKTOP_SESSION,,}
  fi
  echo "$de"
}

# Detect terminal emulator(s) from environment or common process names
get_terminals() {
  local terms=()
  # Check $TERM_PROGRAM or common terminal process names
  # Add more terminals if needed
  for t in gnome-terminal konsole alacritty kitty xfce4-terminal mate-terminal; do
    if pgrep -x "$t" > /dev/null 2>&1; then
      terms+=("$t")
    fi
  done
  echo "${terms[@]}"
}

DISTRO_NAME=$(get_distro)
DESKTOP_ENV=$(get_desktop_env)
TERMINALS=$(get_terminals)

# Fonts and sizes
FONT_ALIAS="Hack Nerd Font"
GENERAL_FONT_SIZE="12"
FIXED_FONT_SIZE="10"
SMALL_FONT_SIZE="8"
OTHER_FONT_SIZE="10"

# Download and install Hack Nerd Font system-wide
TMPDIR=$(mktemp -d)
wget -O "$TMPDIR/Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip "$TMPDIR/Hack.zip" -d "$TMPDIR/Hack"
sudo mkdir -p /usr/local/share/fonts/nerd-fonts
sudo mv "$TMPDIR/Hack/"*.ttf "$TMPDIR/Hack/"*.otf /usr/local/share/fonts/nerd-fonts/
sudo fc-cache -fv

# Apply fonts for Desktop Environments

case "$DESKTOP_ENV" in
  *kde*)
    if command -v kwriteconfig5 &>/dev/null; then
      kwriteconfig5 --file kdeglobals --group General --key font "$FONT_ALIAS,$GENERAL_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group Fixed --key font "$FONT_ALIAS,$FIXED_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group Small --key font "$FONT_ALIAS,$SMALL_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group Toolbar --key font "$FONT_ALIAS,$OTHER_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group Menu --key font "$FONT_ALIAS,$OTHER_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group "Window Title" --key font "$FONT_ALIAS,$OTHER_FONT_SIZE,-1,5,50,0,0,0,0,0"
      kwriteconfig5 --file kdeglobals --group General --key antialiasing "true"
      kwriteconfig5 --file kdeglobals --group General --key hinting "slight"
      kwriteconfig5 --file kdeglobals --group General --key subpixelRendering "rgb"
      kwriteconfig5 --file kdeglobals --group General --key forceFontDpi 96
    fi
    # KDE Konsole font in all profiles
    find ~/.local/share/konsole -name "*.profile" -exec sed -i "s/^Font=.*/Font=$FONT_ALIAS $GENERAL_FONT_SIZE/" {} \;
    ;;
  *gnome*|*cinnamon*)
    if command -v gsettings &>/dev/null; then
      gsettings set org.gnome.desktop.interface font-name "$FONT_ALIAS $GENERAL_FONT_SIZE"
      gsettings set org.gnome.desktop.interface monospace-font-name "$FONT_ALIAS $FIXED_FONT_SIZE"
      if [[ "$DESKTOP_ENV" == *gnome* ]] && command -v dconf &>/dev/null; then
        for profile in $(dconf list /org/gnome/terminal/legacy/profiles:/ | grep -oP '[^/]+' | sort | uniq); do
          dconf write "/org/gnome/terminal/legacy/profiles:/:$profile/font" "'$FONT_ALIAS $FIXED_FONT_SIZE'"
        done
      fi
    fi
    ;;
  *xfce*)
    xfconf-query -c xsettings -p /Gtk/FontName -s "$FONT_ALIAS $GENERAL_FONT_SIZE"
    xfconf-query -c xfwm4 -p /general/font -s "$FONT_ALIAS $GENERAL_FONT_SIZE"
    xfce_term_conf="$HOME/.config/xfce4/terminal/terminalrc"
    if [ -f "$xfce_term_conf" ]; then
      sed -i "s/^FontName=.*/FontName=$FONT_ALIAS $FIXED_FONT_SIZE/" "$xfce_term_conf"
    fi
    ;;
  *mate*)
    if command -v gsettings &>/dev/null; then
      gsettings set org.mate.interface font-name "$FONT_ALIAS $GENERAL_FONT_SIZE"
    fi
    ;;
  *)
    # Generic fallback for desktops not specifically recognized
    echo "Unknown or unsupported desktop $DESKTOP_ENV, font set might be partial."
    ;;
esac

# Apply fonts for terminal emulators detected

for term in $TERMINALS; do
  case $term in
    gnome-terminal)
      # Already handled via dconf in GNOME case
      ;;
    konsole)
      find ~/.local/share/konsole -name "*.profile" -exec sed -i "s/^Font=.*/Font=$FONT_ALIAS $GENERAL_FONT_SIZE/" {} \;
      ;;
    alacritty)
      alacritty_conf="$HOME/.config/alacritty/alacritty.yml"
      if [ -f "$alacritty_conf" ]; then
        sed -i "/^ *family:/c\  family: \"$FONT_ALIAS\"" "$alacritty_conf"
        sed -i "/^ *size:/c\  size: $GENERAL_FONT_SIZE" "$alacritty_conf"
      fi
      ;;
    kitty)
      kitty_conf="$HOME/.config/kitty/kitty.conf"
      if [ -f "$kitty_conf" ]; then
        sed -i "/^font_family/c\font_family $FONT_ALIAS" "$kitty_conf"
        sed -i "/^font_size/c\font_size $GENERAL_FONT_SIZE" "$kitty_conf"
      fi
      ;;
    xfce4-terminal)
      xfce_term_conf="$HOME/.config/xfce4/terminal/terminalrc"
      if [ -f "$xfce_term_conf" ]; then
        sed -i "s/^FontName=.*/FontName=$FONT_ALIAS $FIXED_FONT_SIZE/" "$xfce_term_conf"
      fi
      ;;
    mate-terminal)
      # Mate terminal config editing would be needed here if required
      ;;
  esac
done

# Set console (TTY) font (supports bitmap fonts - approximate)
if grep -q "FONT=" /etc/vconsole.conf; then
  sudo sed -i "s/^FONT=.*/FONT=\"$FONT_ALIAS-Regular\"/" /etc/vconsole.conf
else
  echo "FONT=\"$FONT_ALIAS-Regular\"" | sudo tee -a /etc/vconsole.conf
fi

# Global fontconfig fallback for monospace font
sudo tee /etc/fonts/local.conf > /dev/null <<EOF
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>$FONT_ALIAS</family>
    </prefer>
  </alias>
</fontconfig>
EOF

rm -rf "$TMPDIR"

desktop_msg="${DESKTOP_ENV^}"
terminal_list=$(echo $TERMINALS | tr ' ' ', ')

echo "Hack Nerd Font installed."
echo "Applied to desktop environment: $desktop_msg."
echo "Applied to terminal(s): $terminal_list."
echo "Please restart your desktop session or reboot to ensure complete font application."
