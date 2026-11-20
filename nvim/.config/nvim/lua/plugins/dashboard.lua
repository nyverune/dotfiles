return {
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                [[                                                                        ]],
                [[  ███╗   ██╗██╗   ██╗██╗   ██╗███████╗██████╗ ██╗   ██╗███╗   ██╗███████╗  ]],
                [[  ████╗  ██║╚██╗ ██╔╝██║   ██║██╔════╝██╔══██╗██║   ██║████╗  ██║██╔════╝  ]],
                [[  ██╔██╗ ██║ ╚████╔╝ ██║   ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║█████╗    ]],
                [[  ██║╚██╗██║  ╚██╔╝  ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██╔══╝    ]],
                [[  ██║ ╚████║   ██║    ╚████╔╝ ███████╗██║  ██║╚██████╔╝██║ ╚████║███████╗  ]],
                [[  ╚═╝  ╚═══╝   ╚═╝     ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝  ]],
                [[                                                                        ]],
                [[                 ✨ Nyverune Development Environment ✨                 ]],
            }

            local function button(sc, txt, keybind)
                local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")
                local opts = {
                    position = "center",
                    text = txt,
                    shortcut = "[" .. sc .. "]",
                    cursor = 3,
                    width = 44,
                    align_shortcut = "right",
                    hl_shortcut = "AlphaButtonShortcut",
                    hl = "AlphaButton",
                }
                if keybind then
                    opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true, nowait = true } }
                end
                return {
                    type = "button",
                    val = txt,
                    on_press = function()
                        local key = vim.api.nvim_replace_termcodes(keybind or sc_, true, false, true)
                        vim.api.nvim_feedkeys(key, "normal", false)
                    end,
                    opts = opts,
                }
            end

            dashboard.section.buttons.val = {
                button("f", "  Find File", "<cmd>Telescope find_files<cr>"),
                button("r", "  Recent Files", "<cmd>Telescope oldfiles<cr>"),
                button("g", "󰈬  Find Text (Grep)", "<cmd>Telescope live_grep<cr>"),
                button("e", "  New File", "<cmd>ene <BAR> startinsert<cr>"),
                button("t", "󰙅  File Explorer", "<cmd>NvimTreeToggle<cr>"),
                button("l", "󰒲  Lazy Plugins", "<cmd>Lazy<cr>"),
                button("m", "󱌢  Mason LSP", "<cmd>Mason<cr>"),
                button("q", "󰩈  Quit Neovim", "<cmd>qa<cr>"),
            }

            local function footer()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                return "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
            end

            dashboard.section.footer.val = footer()

            -- Custom Highlights
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.footer.opts.hl = "AlphaFooter"

            dashboard.opts.layout[1].val = 4 -- top padding

            alpha.setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                callback = function()
                    dashboard.section.footer.val = footer()
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },
}
