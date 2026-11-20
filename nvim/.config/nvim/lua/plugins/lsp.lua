return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })

            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = {
                    "pyright",        -- Python LSP
                    "rust_analyzer",  -- Rust LSP
                    "marksman",       -- Markdown LSP
                    "lua_ls",         -- Lua LSP
                },
            })

            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(client, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end

                map("gd", vim.lsp.buf.definition, "Goto Definition")
                map("gr", vim.lsp.buf.references, "Goto References")
                map("gI", vim.lsp.buf.implementation, "Goto Implementation")
                map("K", vim.lsp.buf.hover, "Hover Documentation")
                map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
                map("<leader>d", vim.diagnostic.open_float, "Show Diagnostics")
                map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
                map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
            end

            -- Setup servers directly
            local servers = { "pyright", "rust_analyzer", "marksman", "lua_ls" }
            for _, server in ipairs(servers) do
                local opts = {
                    capabilities = capabilities,
                    on_attach = on_attach,
                }
                if server == "lua_ls" then
                    opts.settings = {
                        Lua = {
                            diagnostics = { globals = { "vim", "Quickshell" } },
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                        },
                    }
                elseif server == "rust_analyzer" then
                    opts.settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = { command = "clippy" },
                        },
                    }
                elseif server == "pyright" then
                    opts.settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    }
                end
                lspconfig[server].setup(opts)
            end

            -- UI styling for diagnostic signs
            local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded" },
            })
        end,
    },
}
