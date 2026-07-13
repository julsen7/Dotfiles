#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Dotfiles/wallpaper"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    dunstify "Wallpaper Error" "Folder $WALLPAPER_DIR does not exist!" -u critical
    exit 1
fi

shopt -s nullglob
WALLPAPERS=( "$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp} )
shopt -u nullglob

if (( ${#WALLPAPERS[@]} == 0 )); then
    dunstify "Wallpaper Error" "Folder $WALLPAPER_DIR does not contain correct images!" -u critical
    exit 1
fi

menu_items=""
for full_path in "${WALLPAPERS[@]}"; do
    basename=$(basename "$full_path")
    menu_items+="${basename}\0icon\x1f${full_path}\n"
done

SELECTED_NAME=$(echo -e "$menu_items" | rofi -dmenu)

if [[ -n "$SELECTED_NAME" ]]; then
    WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED_NAME"
    
    cp "$WALLPAPER_PATH" "$HOME/Dotfiles/.config/hypr/current_wallpaper"

    matugen image "$WALLPAPER_PATH" --source-color-index 0 >/dev/null 2>&1

    dunstify "Wallpaper" "Set $SELECTED_NAME as wallpaper" -i "$WALLPAPER_PATH"
fi
