if vim.loader then
  vim.loader.enable()
end

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("plugins.icons")
require("plugins.rose-pine")
require("plugins.heirline")
