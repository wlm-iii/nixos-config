#!/usr/bin/env bash
workspace=$(rofi -dmenu read -p "Enter a workspace name: ")
[[ -n $workspace ]] || exit 0
hyprctl dispatch "hl.dsp.window.move({workspace = \"name:${workspace}\"})"
