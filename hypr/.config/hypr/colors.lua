-- ===============================================
-- Nyverune Hyprland - Dynamic Pywal Color Integration
-- Reads ~/.cache/wal/colors with fallback to official Nyverune tokens
-- https://github.com/nyverune/brand
-- ===============================================

local colors = {}

local function read_wal_colors()
    local home = os.getenv("HOME") or ""
    local f = io.open(home .. "/.cache/wal/colors", "r")
    if not f then return nil end

    local hex_list = {}
    for line in f:lines() do
        local clean = line:gsub("^%s*#?", ""):gsub("%s*$", "")
        if #clean >= 6 then
            table.insert(hex_list, clean:sub(1, 6))
        end
    end
    f:close()
    return hex_list
end

local wal = read_wal_colors() or {}

-- Palette extraction with official Nyverune brand fallback
colors.bg        = wal[1]  or "100D16"
colors.error     = wal[2]  or "FF5C72"
colors.success   = wal[3]  or "75D6A3"
colors.warning   = wal[4]  or "FFC36B"
colors.info      = wal[5]  or "72B7FF"
colors.primary   = wal[6]  or "A855F7"
colors.accent    = wal[7]  or "C084FC"
colors.fg        = wal[8]  or "F6F0FC"
colors.border    = wal[9]  or "2E2242"
colors.secondary = wal[14] or "FF5CB8"

-- Hyprland color format helpers
colors.rgba = function(hex, alpha)
    alpha = alpha or "ff"
    return "rgba(" .. hex .. alpha .. ")"
end

colors.hex_int = function(hex, alpha)
    alpha = alpha or "ee"
    return tonumber("0x" .. alpha .. hex) or 0xee1a1a1a
end

return colors
