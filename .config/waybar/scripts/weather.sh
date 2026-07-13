#!/usr/bin/env bash

STADT="Aachen"

text=$(curl -s "https://wttr.in/${STADT}?format=%c%t" | sed -E 's/\+//g; s/\x1b\[[0-9;]*m//g' | sed -E 's/\s+/ /g')

if [ -z "$text" ] || [[ "$text" == *"Error"* ]] || [[ "$text" == *"Unknown"* ]]; then
    echo '{"text": "N/A", "tooltip": "Weather service not reachable"}'
    exit 1
fi

tooltip=$(curl -s "https://wttr.in/${STADT}?format=%l:+%C+%t+%w+%m" | sed -E 's/\+//g; s/\x1b\[[0-9;]*m//g' | sed -E 's/\s+/ /g')

echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
