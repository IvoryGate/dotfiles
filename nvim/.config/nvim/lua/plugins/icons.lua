local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/nvim-mini/mini.icons" }, pack_opts)

package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end

require("mini.icons").setup()

local function icon(code)
  return vim.fn.nr2char(code)
end

local mini_icons = require("mini.icons")

local I = {
  folder = icon(0xf07b),
  folder_open = icon(0xf115),
  folder_empty = icon(0xf114),
  file = icon(0xf15c),
  fold_open = icon(0xf078),
  fold_close = icon(0xf078),
  chevron_left = icon(0xf053),
  chevron_right = icon(0xf054),
  close = icon(0xf00d),
  terminal = icon(0xf120),
  git_add = icon(0xf067),
  git_delete = icon(0xf068),
  git_change = icon(0xf044),
  git_rename = icon(0xf064),
  git_untracked = icon(0xf059),
  git_ignored = icon(0xf05c),
  git_staged = icon(0xf055),
  git_unstaged = icon(0xf061),
  git_conflict = icon(0xf071),
  diag_error = icon(0xf057),
  diag_warn = icon(0xf071),
  diag_hint = icon(0xf059),
  diag_info = icon(0xf05a),
  search = icon(0xf002),
  recent = icon(0xf017),
  explorer = icon(0xf115),
  quit = icon(0xf057),
}

vim.opt.fillchars = vim.tbl_extend("force", vim.opt.fillchars:get(), {
  eob = " ",
  foldopen = I.fold_open,
  foldclose = I.fold_close,
  foldsep = " ",
})

return setmetatable({ mini = mini_icons }, {
  __index = I,
})
