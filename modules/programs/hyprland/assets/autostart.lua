-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar &")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("systemctl --user start hyprpaper")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 20")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
