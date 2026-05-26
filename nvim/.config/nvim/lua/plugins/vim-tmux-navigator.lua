if vim.env.TMUX and vim.env.TMUX ~= "" then
  vim.g.tmux_navigator_no_mappings = 1
  vim.pack.add({ "https://github.com/christoomey/vim-tmux-navigator" }, { load = true, confirm = false })

  vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { desc = "Tmux / window left" })
  vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { desc = "Tmux / window down" })
  vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { desc = "Tmux / window up" })
  vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { desc = "Tmux / window right" })
else
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
end
