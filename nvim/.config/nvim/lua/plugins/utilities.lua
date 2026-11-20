return {
    -- Auto-close parentheses, brackets, quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true,
        },
    },

    -- Git signs in gutter
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
                end

                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
                map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
            end,
        },
    },

    -- Which-Key interactive helper
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
        },
    },

    -- Comment toggle with gcc / gc
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },
}
