return {
    -- Material-style Web Devicons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = false,
        priority = 1000,
        opts = {
            default = true,
            strict = true,
            override_by_extension = {
                ["py"] = { icon = "", color = "#FFD43B", name = "Python" },
                ["rs"] = { icon = "", color = "#DEA584", name = "Rust" },
                ["md"] = { icon = "", color = "#519ABA", name = "Markdown" },
                ["lua"] = { icon = "", color = "#51A0CF", name = "Lua" },
                ["toml"] = { icon = "", color = "#9C4221", name = "Toml" },
                ["json"] = { icon = "", color = "#CBCB41", name = "Json" },
                ["yaml"] = { icon = "", color = "#6D8086", name = "Yaml" },
                ["yml"] = { icon = "", color = "#6D8086", name = "Yml" },
                ["lock"] = { icon = "", color = "#BBBBBB", name = "Lock" },
            },
        },
    },

    -- Bufferline / Tabs at Top
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = {
            options = {
                mode = "buffers",
                separator_style = "thin",
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                color_icons = true,
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "center",
                        separator = true,
                    },
                },
            },
        },
    },

    -- Lualine Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = function()
            local theme = require("config.theme")
            local c = theme.get_wal_colors()

            local custom_theme = {
                normal = {
                    a = { fg = c.bg, bg = c.c5, gui = "bold" },
                    b = { fg = c.fg, bg = c.c0 },
                    c = { fg = c.fg, bg = c.bg },
                },
                insert = {
                    a = { fg = c.bg, bg = c.c2, gui = "bold" },
                    b = { fg = c.fg, bg = c.c0 },
                    c = { fg = c.fg, bg = c.bg },
                },
                visual = {
                    a = { fg = c.bg, bg = c.c3, gui = "bold" },
                    b = { fg = c.fg, bg = c.c0 },
                    c = { fg = c.fg, bg = c.bg },
                },
                replace = {
                    a = { fg = c.bg, bg = c.c1, gui = "bold" },
                    b = { fg = c.fg, bg = c.c0 },
                    c = { fg = c.fg, bg = c.bg },
                },
                command = {
                    a = { fg = c.bg, bg = c.c4, gui = "bold" },
                    b = { fg = c.fg, bg = c.c0 },
                    c = { fg = c.fg, bg = c.bg },
                },
                inactive = {
                    a = { fg = c.c8, bg = c.c0 },
                    b = { fg = c.c8, bg = c.c0 },
                    c = { fg = c.c8, bg = c.bg },
                },
            }

            return {
                options = {
                    theme = custom_theme,
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { { "mode", icon = "" } },
                    lualine_b = { { "branch", icon = "" }, "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { { "location", icon = "" } },
                },
            }
        end,
    },
}
