-- ===============================================
-- Nyverune Hyprland Configuration (Lua)
-- Main entry point
-- https://github.com/nyverune/brand
-- ===============================================

-- Ensure ~/.config/hypr is in the Lua module search path
local config_dir = os.getenv("HOME") .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

-- 1. Monitors
require("monitors")

-- 2. Programs
require("programs")

-- 3. Environment Variables
require("env")

-- 4. Autostart Processes
require("autostart")

-- 5. Appearance, Animations & Layouts
require("appearance")

-- 6. Input & Gestures
require("input")

-- 7. Keybindings & Shortcuts
require("keybinds")

-- 8. Window & Workspace Rules
require("rules")
