if vim.loader then
  vim.loader.enable()
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lsp")

require("plugins.icons")
require("plugins.rose-pine")
require("plugins.heirline")
require("plugins.which-key")
require("plugins.neo-tree")
require("plugins.aerial")
require("plugins.vim-tmux-navigator")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.debugging")
require("plugins.overseer")
require("plugins.gitsigns")
require("plugins.snacks")
require("plugins.markdown")
require("plugins.img-clip")
