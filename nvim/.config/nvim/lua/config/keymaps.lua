vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local others = vim.tbl_filter(function(b)
    return b ~= bufnr and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  if #others == 0 then
    vim.cmd("qa")
    return
  end
  vim.api.nvim_win_set_buf(0, others[1])
  pcall(vim.api.nvim_buf_delete, bufnr, {})
end, { desc = "Close current buffer" })

vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>\\", ":split<CR>", { desc = "Split horizontally" })

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jk", "<Esc>:write<CR>", { desc = "Exit insert and save" })
