local M = {}

function M.get_wal_colors()
    local path = vim.fn.expand("~/.cache/wal/colors.json")
    if vim.fn.filereadable(path) == 1 then
        local content = vim.fn.readfile(path)
        local ok, data = pcall(vim.fn.json_decode, table.concat(content, ""))
        if ok and data then
            local special = data.special or {}
            local palette = data.colors or {}
            return {
                bg = special.background or "#100D16",
                fg = special.foreground or "#F6F0FC",
                cursor = special.cursor or "#F6F0FC",
                c0 = palette.color0 or "#100D16",
                c1 = palette.color1 or "#FF5C72",
                c2 = palette.color2 or "#75D6A3",
                c3 = palette.color3 or "#FFC36B",
                c4 = palette.color4 or "#72B7FF",
                c5 = palette.color5 or "#A855F7",
                c6 = palette.color6 or "#C084FC",
                c7 = palette.color7 or "#F6F0FC",
                c8 = palette.color8 or "#2E2242",
                c9 = palette.color9 or "#FF5C72",
                c10 = palette.color10 or "#75D6A3",
                c11 = palette.color11 or "#FFC36B",
                c12 = palette.color12 or "#72B7FF",
                c13 = palette.color13 or "#A855F7",
                c14 = palette.color14 or "#C084FC",
                c15 = palette.color15 or "#FFFFFF",
            }
        end
    end
    -- Fallback Nyverune palette
    return {
        bg = "#100D16", fg = "#F6F0FC", cursor = "#F6F0FC",
        c0 = "#181224", c1 = "#FF5C72", c2 = "#75D6A3", c3 = "#FFC36B",
        c4 = "#72B7FF", c5 = "#A855F7", c6 = "#C084FC", c7 = "#F6F0FC",
        c8 = "#2E2242", c9 = "#FF5C72", c10 = "#75D6A3", c11 = "#FFC36B",
        c12 = "#72B7FF", c13 = "#A855F7", c14 = "#C084FC", c15 = "#FFFFFF"
    }
end

function M.apply()
    local c = M.get_wal_colors()
    vim.g.colors_name = "nyverune-wal"
    vim.o.termguicolors = true
    vim.o.background = "dark"

    local set = vim.api.nvim_set_hl

    -- Base Editor
    set(0, "Normal", { fg = c.fg, bg = c.bg })
    set(0, "NormalFloat", { fg = c.fg, bg = c.c0 })
    set(0, "FloatBorder", { fg = c.c5, bg = c.c0 })
    set(0, "Cursor", { fg = c.bg, bg = c.cursor })
    set(0, "CursorLine", { bg = c.c0 })
    set(0, "CursorLineNr", { fg = c.c5, bold = true })
    set(0, "LineNr", { fg = c.c8 })
    set(0, "SignColumn", { bg = c.bg })
    set(0, "VertSplit", { fg = c.c8, bg = c.bg })
    set(0, "WinSeparator", { fg = c.c8, bg = c.bg })
    set(0, "ColorColumn", { bg = c.c0 })
    set(0, "StatusLine", { fg = c.fg, bg = c.c0 })
    set(0, "StatusLineNC", { fg = c.c8, bg = c.bg })
    set(0, "Pmenu", { fg = c.fg, bg = c.c0 })
    set(0, "PmenuSel", { fg = c.bg, bg = c.c5, bold = true })
    set(0, "PmenuSbar", { bg = c.c0 })
    set(0, "PmenuThumb", { bg = c.c8 })
    set(0, "Visual", { bg = c.c8 })
    set(0, "Search", { fg = c.bg, bg = c.c3 })
    set(0, "IncSearch", { fg = c.bg, bg = c.c5 })

    -- Syntax Highlighting
    set(0, "Comment", { fg = c.c8, italic = true })
    set(0, "Constant", { fg = c.c3 })
    set(0, "String", { fg = c.c2 })
    set(0, "Character", { fg = c.c2 })
    set(0, "Number", { fg = c.c3 })
    set(0, "Boolean", { fg = c.c3, bold = true })
    set(0, "Float", { fg = c.c3 })
    set(0, "Identifier", { fg = c.fg })
    set(0, "Function", { fg = c.c4, bold = true })
    set(0, "Statement", { fg = c.c5, bold = true })
    set(0, "Conditional", { fg = c.c5 })
    set(0, "Repeat", { fg = c.c5 })
    set(0, "Label", { fg = c.c5 })
    set(0, "Operator", { fg = c.c6 })
    set(0, "Keyword", { fg = c.c5, bold = true })
    set(0, "Exception", { fg = c.c1 })
    set(0, "PreProc", { fg = c.c6 })
    set(0, "Type", { fg = c.c4 })
    set(0, "Structure", { fg = c.c5 })
    set(0, "Special", { fg = c.c6 })
    set(0, "Underlined", { underline = true })
    set(0, "Error", { fg = c.c1, bold = true })
    set(0, "Todo", { fg = c.bg, bg = c.c3, bold = true })

    -- Treesitter groups
    set(0, "@variable", { fg = c.fg })
    set(0, "@variable.builtin", { fg = c.c6 })
    set(0, "@variable.parameter", { fg = c.c7 })
    set(0, "@function", { fg = c.c4, bold = true })
    set(0, "@function.builtin", { fg = c.c4 })
    set(0, "@keyword", { fg = c.c5, bold = true })
    set(0, "@keyword.return", { fg = c.c5, bold = true })
    set(0, "@string", { fg = c.c2 })
    set(0, "@type", { fg = c.c4 })
    set(0, "@type.builtin", { fg = c.c4 })
    set(0, "@property", { fg = c.c6 })
    set(0, "@comment", { fg = c.c8, italic = true })

    -- Diagnostics
    set(0, "DiagnosticError", { fg = c.c1 })
    set(0, "DiagnosticWarn", { fg = c.c3 })
    set(0, "DiagnosticInfo", { fg = c.c4 })
    set(0, "DiagnosticHint", { fg = c.c2 })

    -- GitSigns
    set(0, "GitSignsAdd", { fg = c.c2 })
    set(0, "GitSignsChange", { fg = c.c3 })
    set(0, "GitSignsDelete", { fg = c.c1 })

    -- NvimTree
    set(0, "NvimTreeNormal", { fg = c.fg, bg = c.c0 })
    set(0, "NvimTreeEndOfBuffer", { fg = c.c0, bg = c.c0 })
    set(0, "NvimTreeRootFolder", { fg = c.c5, bold = true })
    set(0, "NvimTreeFolderName", { fg = c.c4 })
    set(0, "NvimTreeFolderIcon", { fg = c.c4 })
    set(0, "NvimTreeOpenedFolderName", { fg = c.c5, bold = true })
    set(0, "NvimTreeWinSeparator", { fg = c.c8, bg = c.c0 })

    -- BufferLine
    set(0, "BufferLineFill", { bg = c.c0 })
    set(0, "BufferLineBackground", { fg = c.c8, bg = c.c0 })
    set(0, "BufferLineBufferSelected", { fg = c.fg, bg = c.bg, bold = true })
    set(0, "BufferLineIndicatorSelected", { fg = c.c5, bg = c.bg })
    set(0, "BufferLineSeparator", { fg = c.c0, bg = c.c0 })
    set(0, "BufferLineSeparatorSelected", { fg = c.c0, bg = c.bg })

    -- Alpha Dashboard
    set(0, "AlphaHeader", { fg = c.c5, bold = true })
    set(0, "AlphaButton", { fg = c.fg })
    set(0, "AlphaButtonShortcut", { fg = c.c3, bold = true })
    set(0, "AlphaFooter", { fg = c.c8, italic = true })
end

M.apply()

-- Auto reload when pywal colors update
local group = vim.api.nvim_create_augroup("NyveruneWalReload", { clear = true })
vim.api.nvim_create_autocmd("Signal", {
    group = group,
    pattern = "SIGUSR1",
    callback = function()
        M.apply()
    end,
})

return M
