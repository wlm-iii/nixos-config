#!/usr/bin/env bash
workspace=$(
    rofi -dmenu -sync -p "Enter a workspace name:" </dev/null
)
[[ -n $workspace ]] || exit 0
hyprctl dispatch "hl.dsp.window.move({workspace = \"name:${workspace}\"})"
