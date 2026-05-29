local M = {}

M.is_lsp_attached = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  return next(clients) ~= nil
end

M.mason_bin = function(name)
  local path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason/bin", name)
  if vim.fn.executable(path) == 1 then
    return path
  end
  return vim.fn.exepath(name)
end

M.reset_overseerlist_width = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == "OverseerList" then
      vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.2))
      break
    end
  end
end

M.func_on_window = function(window_name, fn)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == window_name then
      fn()
      break
    end
  end
end

return M
