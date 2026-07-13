#!/usr/bin/env bash

DUNST_DIR="$HOME/Dotfiles/.config/dunst"
HYPR_DIR="$HOME/Dotfiles/.config/hypr"
KITTY_DIR="$HOME/Dotfiles/.config/kitty"
OBS_DIR="$HOME/Dotfiles/.config/obs-studio"
ROFI_DIR="$HOME/Dotfiles/.config/rofi"
SPICETIFY_DIR="$HOME/Dotfiles/.config/spicetify"
WAYBAR_DIR="$HOME/Dotfiles/.config/waybar"

BW_ICON="$HOME/Dotfiles/scripts/blackwhite.jpg"
COLOR_ICON="$HOME/Dotfiles/scripts/colorful.jpg"

themes=(
    "Black & White\0icon\x1f${BW_ICON}"
    "Colorful\0icon\x1f${COLOR_ICON}"
)

SELECTED_THEME=$(printf "%b\n" "${themes[@]}" | rofi -dmenu -p "Theme Selector")

if [[ -n "$SELECTED_THEME" ]]; then
    
    if [[ "$SELECTED_THEME" == "Black & White" ]]; then
        ln -sf "$DUNST_DIR/themes/blackwhite" "$DUNST_DIR/dunstrc"
        ln -sf "$HYPR_DIR/themes/blackwhite.lua" "$HYPR_DIR/colors.lua"
        ln -sf "$HYPR_DIR/themes/blackwhite.conf" "$HYPR_DIR/colors.conf"
        ln -sf "$KITTY_DIR/themes/blackwhite.conf" "$KITTY_DIR/current-theme.conf"
        sed -i 's/Theme=com.obsproject.colorful/Theme=com.obsproject.Yami.Acri/g' "$OBS_DIR/user.ini"
        ln -sf "$ROFI_DIR/themes/blackwhite.rasi" "$ROFI_DIR/colors.rasi"
        ln -sf "$SPICETIFY_DIR/Themes/Theme/blackwhite.ini" "$SPICETIFY_DIR/Themes/Theme/color.ini"
        ln -sf "$WAYBAR_DIR/themes/blackwhite.css" "$WAYBAR_DIR/colors.css"

        dunstify "Theme Selector" "Black-White theme selected" -i "$BW_ICON"
        
    elif [[ "$SELECTED_THEME" == "Colorful" ]]; then
        ln -sf "$DUNST_DIR/themes/colorful" "$DUNST_DIR/dunstrc"
        ln -sf "$HYPR_DIR/themes/colorful.lua" "$HYPR_DIR/colors.lua"
        ln -sf "$HYPR_DIR/themes/colorful.conf" "$HYPR_DIR/colors.conf"
        ln -sf "$KITTY_DIR/themes/colorful.conf" "$KITTY_DIR/current-theme.conf"
        sed -i 's/Theme=com.obsproject.Yami.Acri/Theme=com.obsproject.colorful/g' "$OBS_DIR/user.ini"
        ln -sf "$ROFI_DIR/themes/colorful.rasi" "$ROFI_DIR/colors.rasi"
        ln -sf "$SPICETIFY_DIR/Themes/Theme/colorful.ini" "$SPICETIFY_DIR/Themes/Theme/color.ini"
        ln -sf "$WAYBAR_DIR/themes/colorful.css" "$WAYBAR_DIR/colors.css"
        
        dunstify "Theme Selector" "Colorful theme selected" -i "$COLOR_ICON"
    fi

    dunstctl reload
    killall -SIGUSR1 kitty 2>/dev/null
    spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q"
    pkill -SIGUSR2 waybar
fi
