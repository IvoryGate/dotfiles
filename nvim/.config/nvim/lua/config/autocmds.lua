local augroup = vim.api.nvim_create_augroup("IvoryGateNvim", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.schedule(function()
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        vim.api.nvim_tabpage_set_win(tab, vim.api.nvim_tabpage_get_win(tab))
      end
    end)
  end,
})
