-- ==============================================================================
-- Nyverune Neovim Configuration
-- Modern, fast, and dynamically themed with Pywal
-- https://github.com/nyverune
-- ==============================================================================

-- Ensure user binaries (~/.local/bin, ~/.local/share/node/bin, ~/go/bin, ~/.cargo/bin) are in PATH for Mason & LSPs
local home = vim.fn.expand("~")
vim.env.PATH = home .. "/.local/bin:" .. home .. "/.local/share/node/bin:" .. home .. "/go/bin:" .. home .. "/.cargo/bin:" .. (vim.env.PATH or "")

require("config.options")
require("config.keymaps")
require("config.theme")
require("config.lazy")
