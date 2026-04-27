-- 软换行：wrap + linebreak + breakindent
-- 右侧留白：原生没有「软换行距右缘空 N 列」；用 rickhowe/wrapwidth 的虚拟空白实现（:Wrapwidth -N）
-- 左侧不额外加宽（行号区保持默认）

local RIGHT_WRAP_MARGIN = 4 -- 距窗口右边缘的虚拟留白列数，可按喜好改

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.opt = vim.tbl_deep_extend("force", opts.options.opt or {}, {
        wrap = true,
        linebreak = true,
        breakindent = true,
        breakindentopt = "shift:2,min:20,sbr",
        showbreak = "  ",
        scrolloff = 6,
      })
      if vim.fn.has "nvim-0.10" == 1 then opts.options.opt.smoothscroll = true end
      return opts
    end,
  },
  {
    "rickhowe/wrapwidth",
    event = { "VeryLazy", "BufWinEnter", "VimResized", "WinResized" },
    config = function()
      local group = vim.api.nvim_create_augroup("dotfiles-wrapwidth", { clear = true })
      local cmd = ("Wrapwidth -%d"):format(RIGHT_WRAP_MARGIN)

      local function apply_current()
        if vim.wo.wrap then vim.cmd(cmd) end
      end

      local function apply_tabpage()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          vim.api.nvim_win_call(win, function()
            if vim.wo.wrap then vim.cmd(cmd) end
          end)
        end
      end

      vim.api.nvim_create_autocmd("BufWinEnter", { group = group, callback = apply_current })
      vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, { group = group, callback = apply_tabpage })
      apply_tabpage()
    end,
  },
}
