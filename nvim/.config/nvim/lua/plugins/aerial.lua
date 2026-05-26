local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/stevearc/aerial.nvim" }, pack_opts)

require("aerial").setup({
  attach_mode = "global",
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = { min_width = 28 },
  show_guides = true,
  filter_kind = false,
  guides = {
    mid_item = "├ ",
    last_item = "└ ",
    nested_top = "│ ",
    whitespace = "  ",
  },
  keymaps = {
    ["[y"] = "actions.prev",
    ["]y"] = "actions.next",
    ["[Y"] = "actions.prev_up",
    ["]Y"] = "actions.next_up",
  },
})

vim.keymap.set("n", "<leader>lS", "<Cmd>AerialToggle<CR>", { desc = "Symbols outline" })
vim.keymap.set("n", "]y", "<Cmd>AerialNext<CR>", { desc = "Next symbol" })
vim.keymap.set("n", "[y", "<Cmd>AerialPrev<CR>", { desc = "Previous symbol" })
