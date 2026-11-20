-- ===============================================
-- Nyverune Hyprland - Environment Variables
-- https://wiki.hypr.land/configuring/core/environment-variables/
-- ===============================================

hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("HOME") .. "/go/bin:" .. (os.getenv("PATH") or ""))
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
