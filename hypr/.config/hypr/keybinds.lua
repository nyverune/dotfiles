-- ===============================================
-- Nyverune Hyprland - Keybindings & Controls
-- https://wiki.hypr.land/configuring/core/binds/
-- ===============================================

local programs    = require("programs")
local terminal    = programs.terminal
local fileManager = programs.fileManager
local menu        = programs.menu

local mainMod = "SUPER"

-- Launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))

-- Power & Session Menu
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("quickshell ipc call powermenu toggle"))
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("quickshell ipc call powermenu toggle"))

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Wallpaper carousel picker
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpapers.sh"))

-- Clipboard history picker (Rofi + Cliphist)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"))

-- Window management
hl.bind(mainMod .. " + K", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10

    hl.bind(mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i }))

    hl.bind(mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",
    hl.dsp.workspace.toggle_special("magic"))

hl.bind(mainMod .. " + SHIFT + S",
    hl.dsp.window.move({ workspace = "special:magic" }))

-- Workspace scrolling
hl.bind(mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" }))

-- Dragging
hl.bind(mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true })

hl.bind(mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true })

-- Laptop multimedia keys for volume, mic and LCD brightness (with OSD)
local osd_cmd = os.getenv("HOME") .. "/.config/hypr/scripts/osd.sh"
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd_cmd .. " volume 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd_cmd .. " volume 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(osd_cmd .. " volume mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(osd_cmd .. " mic mute"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(osd_cmd .. " brightness 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(osd_cmd .. " brightness 5%-"), { locked = true, repeating = true })

-- Spotify Media player controls (playerctl)
hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl --player=spotify next"),
    { locked = true }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl --player=spotify play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl --player=spotify play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl --player=spotify previous"),
    { locked = true }
)

-- Screenshots
hl.bind(
    mainMod .. " + PRINT",
    hl.dsp.exec_cmd("hyprshot -m window -o ~/Screenshots")
)

hl.bind(
    "PRINT",
    hl.dsp.exec_cmd("hyprshot -m output -o ~/Screenshots")
)

hl.bind(
    "SHIFT + PRINT",
    hl.dsp.exec_cmd("hyprshot -m region -o ~/Screenshots")
)

