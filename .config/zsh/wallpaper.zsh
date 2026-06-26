wallpaper() {
    local DIR="~/wallpaper"
    local -a WALLS
    clear

    if [[ ! -d "$DIR" ]]; then
        echo -e "\e[31m X Ordner $DIR existiert nicht!\e[0m"
        return 1
    fi

    WALLS=( "$DIR"/*(N:t) )

    if (( ${#WALLS} == 0 )); then
        echo -e "\e[31m X Ordner $DIR ist leer!\e[0m"
        return 1
    fi

    echo -e "\e[36m=== Wallpaper Selector ===\e[0m\n"
    local i
    for i in {1..${#WALLS}}; do
        echo -e "  \e[35m$i\e[0m) ${WALLS[$i]}"
    done
    echo ""

    echo -ne "\e[36m❯ Hintergrundbild wählen: \e[0m"
    read -r SELECTION

    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#WALLS} )); then
        echo -e "\e[31m X Ungültige Auswahl!\e[0m"
        return 1
    fi

    local SELECTED_WALL="${WALLS[$SELECTION]}"
    local FULL_PATH="$DIR/$SELECTED_WALL"

    echo -e "\e[36m Wende Hintergrundbild und Farbschema an...\e[0m"

    matugen image "$FULL_PATH" -m "dark" >/dev/null 2>&1

    echo -e "\e[32m Aktiviert: $SELECTED_WALL\e[0m"
}
