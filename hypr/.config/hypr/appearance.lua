-- ===============================================
-- Nyverune Hyprland - Look & Feel, Dynamic Theme & Animations
-- https://wiki.hypr.land/configuring/core/config-options/
-- ===============================================

local colors = require("colors")

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Dynamic gradient from Pywal primary to secondary/accent for active window
            active_border   = { colors = { colors.rgba(colors.primary, "ee"), colors.rgba(colors.secondary, "ee") }, angle = 45 },
            -- Muted, translucent border for unfocused windows
            inactive_border = colors.rgba(colors.border, "66"),
        },

        -- Enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        -- Clear differentiation for unfocused windows:
        -- Active windows are fully opaque, unfocused windows get a frosted-glass translucency
        active_opacity     = 1.0,
        inactive_opacity   = 0.86,
        fullscreen_opacity = 1.0,

        -- Dim unfocused windows to bring focal prominence to the active window
        dim_inactive = true,
        dim_strength = 0.18,
        dim_special  = 0.25,

        shadow = {
            enabled        = true,
            range          = 22,
            render_power   = 3,
            -- Focused window has prominent elevation and subtle accent reflection
            color          = colors.hex_int(colors.primary, "44"),
            -- Unfocused windows sit flatter with a subtle dark backdrop
            color_inactive = colors.hex_int(colors.bg, "66"),
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            vibrancy          = 0.2,
            new_optimizations = true,
            -- Allows unfocused translucent windows to blur background wallpaper nicely
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- ===============================================
-- Bezier curves & Springs for lively, organic feel
-- ===============================================
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("overshot",       { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.08}  } })
hl.curve("smoothOut",      { type = "bezier", points = { {0.16, 1},    {0.3, 1}     } })

-- Responsive bouncy springs
hl.curve("springBouncy",   { type = "spring", mass = 1, stiffness = 220, damping = 18 })
hl.curve("springSmooth",   { type = "spring", mass = 1, stiffness = 260, damping = 24 })

-- ===============================================
-- Animation Definitions
-- ===============================================
hl.animation({ leaf = "global",           enabled = true,  speed = 10,  bezier = "default" })

-- Active border animated gradient rotation (loops smoothly)
hl.animation({ leaf = "border",           enabled = true,  speed = 6,   bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",      enabled = true,  speed = 25,  bezier = "linear",       style = "loop" })

-- Window animations: lively pop-in with bouncy spring & snappy exit
hl.animation({ leaf = "windows",          enabled = true,  speed = 5,   spring = "springBouncy" })
hl.animation({ leaf = "windowsIn",        enabled = true,  speed = 4.5, spring = "springBouncy", style = "popin 75%" })
hl.animation({ leaf = "windowsOut",       enabled = true,  speed = 3,   bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "windowsMove",      enabled = true,  speed = 4.5, spring = "springBouncy" })

-- Smooth focus transition animations (dimming, crossfade & opacity switches)
hl.animation({ leaf = "fadeIn",           enabled = true,  speed = 3,   bezier = "smoothOut" })
hl.animation({ leaf = "fadeOut",          enabled = true,  speed = 2.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade",             enabled = true,  speed = 3.5, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch",       enabled = true,  speed = 4,   bezier = "smoothOut" })
hl.animation({ leaf = "fadeDim",          enabled = true,  speed = 4,   bezier = "smoothOut" })

-- Layer animations (notifications, launchers, quickshell, overlays)
hl.animation({ leaf = "layers",           enabled = true,  speed = 4,   spring = "springSmooth" })
hl.animation({ leaf = "layersIn",         enabled = true,  speed = 4,   spring = "springBouncy", style = "popin 80%" })
hl.animation({ leaf = "layersOut",        enabled = true,  speed = 2.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true,  speed = 2.5, bezier = "smoothOut" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true,  speed = 2,   bezier = "almostLinear" })

-- Workspaces animations: modern slidefade for fluid desktop transitions
hl.animation({ leaf = "workspaces",       enabled = true,  speed = 4.5, spring = "springBouncy", style = "slidefade 20%" })
hl.animation({ leaf = "workspacesIn",     enabled = true,  speed = 4.5, spring = "springBouncy", style = "slidefade 20%" })
hl.animation({ leaf = "workspacesOut",    enabled = true,  speed = 4,   bezier = "easeOutQuint", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true,  speed = 4,   spring = "springBouncy", style = "slidevert" })
hl.animation({ leaf = "zoomFactor",       enabled = true,  speed = 7,   bezier = "quick" })

-- ===============================================
-- Layout and Misc Options
-- ===============================================
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
    misc = {
        force_default_wallpaper = 2,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },
})
