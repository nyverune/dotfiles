-- ===============================================
-- Nyverune Hyprland - Autostart Processes
-- https://wiki.hypr.land/configuring/core/autostart/
-- ===============================================

hl.on("hyprland.start", function () 
    hl.exec_cmd("quickshell &")
    hl.exec_cmd("mako &")
    hl.exec_cmd("hyprpaper-start &")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 &")
    hl.exec_cmd("wl-paste --type text --watch ~/.local/bin/cliphist store &")
    hl.exec_cmd("wl-paste --type image --watch ~/.local/bin/cliphist store &")
end)
