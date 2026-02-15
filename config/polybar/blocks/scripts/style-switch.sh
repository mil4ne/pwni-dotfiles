#!/usr/bin/env bash

SDIR="$HOME/.config/polybar/blocks/scripts"

# Launch Rofi
MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
-theme $SDIR/rofi/styles.rasi \
<<< " Gruvbox")"
            case "$MENU" in
				*Gruvbox) "$SDIR"/styles.sh --gruvbox ;;
            esac
