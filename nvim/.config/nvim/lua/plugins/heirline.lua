local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/rebelot/heirline.nvim" }, pack_opts)

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local mini_icons = require("plugins.icons")
local I = mini_icons

local function hl(name)
  return utils.get_highlight(name)
end

local function build_colors()
  return {
    bg = hl("Normal").bg,
    fg = hl("Normal").fg,
    tabline_bg = hl("TabLine").bg,
    tabline_fg = hl("TabLine").fg,
    red = hl("DiagnosticError").fg,
    green = hl("String").fg,
    blue = hl("Function").fg,
    gray = hl("NonText").fg,
    orange = hl("Constant").fg,
    purple = hl("Statement").fg,
    cyan = hl("Special").fg,
    yellow = hl("DiagnosticWarn").fg,
    diag_error = hl("DiagnosticError").fg,
    diag_warn = hl("DiagnosticWarn").fg,
    diag_hint = hl("DiagnosticHint").fg,
    diag_info = hl("DiagnosticInfo").fg,
  }
end

local colors = build_colors()

local function refresh_colors()
  colors = build_colors()
  utils.on_colorscheme(colors)
end

local ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,
  static = {
    mode_names = {
      n = "NORMAL",
      no = "NORMAL",
      nov = "NORMAL",
      noV = "NORMAL",
      ["no\22"] = "NORMAL",
      niI = "NORMAL",
      niR = "NORMAL",
      niV = "NORMAL",
      nt = "TERM",
      v = "VISUAL",
      vs = "VISUAL",
      V = "V-LINE",
      Vs = "V-LINE",
      ["\22"] = "V-BLOCK",
      ["\22s"] = "V-BLOCK",
      s = "SELECT",
      S = "S-LINE",
      ["\19"] = "S-BLOCK",
      i = "INSERT",
      ic = "INSERT",
      ix = "INSERT",
      R = "REPLACE",
      Rc = "REPLACE",
      Rx = "REPLACE",
      c = "COMMAND",
      cv = "COMMAND",
      r = "...",
      rm = "MORE",
      ["r?"] = "CONFIRM",
      ["!"] = "SHELL",
    },
    mode_colors = {
      n = "blue",
      i = "green",
      v = "purple",
      V = "purple",
      ["\22"] = "purple",
      c = "orange",
      R = "cyan",
      s = "purple",
      S = "purple",
      ["\19"] = "purple",
      no = "blue",
      nt = "yellow",
    },
  },
  provider = function(self)
    return " " .. (self.mode_names[self.mode] or self.mode:upper()) .. " "
  end,
  hl = function(self)
    return { bold = true, bg = self.mode_colors[self.mode] or "gray", fg = "bg" }
  end,
  update = { "ModeChanged" },
}

local GitBranch = {
  condition = conditions.is_git_repo,
  provider = function()
    local branch = vim.fn.systemlist("git -C " .. vim.fn.expand("%:p:h") .. " branch --show-current 2> /dev/null")[1]
    return branch ~= "" and ("  " .. branch .. " ") or nil
  end,
  hl = { fg = "orange", bold = true },
}

local FileIcon = {
  init = function(self)
    local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(bufnr)
    name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
    self.icon, self.icon_hl = mini_icons.mini.get("file", name)
  end,
  provider = function(self)
    return (self.icon or "") .. " "
  end,
  hl = function(self)
    return self.icon_hl
  end,
}

local FileName = {
  init = function(self)
    local bufnr = self.bufnr or vim.api.nvim_get_current_buf()
    self.filename = vim.api.nvim_buf_get_name(bufnr)
  end,
  provider = function(self)
    local name = self.filename
    if name == "" then
      return "[No Name]"
    end
    if vim.api.nvim_win_get_width(0) > 100 then
      return vim.fn.fnamemodify(name, ":~:.")
    end
    return vim.fn.fnamemodify(name, ":t")
  end,
  hl = { fg = "fg", bold = true },
}

local Diagnostics = {
  condition = conditions.has_diagnostics,
  init = function(self)
    self.diagnostics = vim.diagnostic.count(0)
  end,
  update = { "DiagnosticChanged" },
  provider = function(self)
    local parts = {}
    local icons = { error = I.diag_error, warn = I.diag_warn, hint = I.diag_hint, info = I.diag_info }
    for kind, icon in pairs(icons) do
      local count = self.diagnostics[kind]
      if count and count > 0 then
        parts[#parts + 1] = icon .. count
      end
    end
    return #parts > 0 and (" " .. table.concat(parts, " ") .. " ") or nil
  end,
  hl = { fg = "gray" },
}

local Lsp = {
  condition = conditions.lsp_attached,
  provider = function()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.name ~= "null-ls" then
        names[#names + 1] = client.name
      end
    end
    return #names > 0 and (" " .. table.concat(names, ", ") .. " ") or nil
  end,
  hl = { fg = "cyan", italic = true },
}

local Location = {
  provider = function()
    return string.format(" %d:%d ", vim.fn.line("."), vim.fn.col("."))
  end,
  hl = { fg = "gray" },
}

local Fill = {
  provider = function()
    return " "
  end,
  hl = { bg = "bg", fg = "bg" },
}

local StatusLine = {
  hl = { fg = "fg", bg = "bg" },
  ViMode,
  GitBranch,
  { provider = " " },
  FileIcon,
  FileName,
  Fill,
  Diagnostics,
  Lsp,
  { provider = "%=" },
  Location,
  ViMode,
}

local TablineFileIcon = {
  init = function(self)
    local name = vim.api.nvim_buf_get_name(self.bufnr)
    name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
    self.icon, self.icon_hl = mini_icons.mini.get("file", name)
  end,
  provider = function(self)
    return self.icon .. " "
  end,
  hl = function(self)
    return self.icon_hl
  end,
}

local TablineFileName = {
  provider = function(self)
    local name = vim.api.nvim_buf_get_name(self.bufnr)
    name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
    return name
  end,
  hl = function(self)
    return { bold = self.is_active or self.is_visible, italic = not self.is_active }
  end,
}

local TablineFlags = {
  {
    condition = function(self)
      return vim.bo[self.bufnr].modified
    end,
    provider = " ●",
    hl = { fg = "green" },
  },
  {
    condition = function(self)
      return vim.bo[self.bufnr].buftype == "terminal"
    end,
    provider = I.terminal,
    hl = { fg = "cyan" },
  },
}

local TablineBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  condition = function(self)
    local ft = vim.bo[self.bufnr].filetype
    return vim.bo[self.bufnr].buflisted and ft ~= "neo-tree" and ft ~= "aerial" and ft ~= "snacks_dashboard"
  end,
  hl = function(self)
    return self.is_active and "TabLineSel" or "TabLine"
  end,
  on_click = {
    callback = function(_, minwid, _, button)
      if button == "m" then
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = "heirline_tabline_buffer",
  },
  TablineFileIcon,
  TablineFileName,
  TablineFlags,
}

local TablineClose = {
  condition = function(self)
    return not vim.bo[self.bufnr].modified
  end,
  provider = " " .. I.close,
  on_click = {
    callback = function(_, minwid)
      vim.schedule(function()
        vim.api.nvim_buf_delete(minwid, { force = false })
        vim.cmd.redrawtabline()
      end)
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = "heirline_tabline_close",
  },
}

local TablineBuffer = utils.surround({ " ", " " }, function(self)
  if self.is_active then
    return hl("TabLineSel").bg
  end
  return hl("TabLine").bg
end, { TablineBlock, TablineClose })

local TablineOffset = {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    self.winid = win
    if ft == "neo-tree" then
      self.title = "Explorer"
      return true
    end
    if ft == "aerial" then
      self.title = "Outline"
      return true
    end
  end,
  provider = function(self)
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.max(0, math.floor((width - #self.title) / 2))
    return string.rep(" ", pad) .. self.title .. string.rep(" ", width - pad - #self.title)
  end,
  hl = function(self)
    return vim.api.nvim_get_current_win() == self.winid and "TabLineSel" or "TabLine"
  end,
}

local TabPages = {
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  { provider = "%=" },
  utils.make_tablist({
    provider = function(self)
      return " Tab " .. self.tabnr .. " "
    end,
    hl = function(self)
      return self.is_active and "TabLineSel" or "TabLine"
    end,
  }),
}

local TabLine = {
  TablineOffset,
  utils.make_buflist(TablineBuffer),
  TabPages,
}

local WinBar = {
  condition = function()
    return vim.bo.filetype ~= "neo-tree" and vim.bo.filetype ~= "aerial" and vim.bo.filetype ~= "snacks_dashboard"
  end,
  init = function(self)
    self.bufnr = vim.api.nvim_get_current_buf()
  end,
  FileIcon,
  {
    provider = function(self)
      local name = vim.api.nvim_buf_get_name(self.bufnr)
      if name == "" then
        return ""
      end
      return vim.fn.fnamemodify(name, ":~:.")
    end,
    hl = { fg = "gray", italic = true },
  },
}

refresh_colors()
require("heirline").setup({
  statusline = StatusLine,
  tabline = TabLine,
  winbar = WinBar,
  opts = {
    colors = colors,
    disable_winbar_cb = function(args)
      local bufname = args.bufname or vim.api.nvim_buf_get_name(args.buf)
      return vim.bo[args.buf].buftype ~= "" or bufname:match("^%[.*%]$")
    end,
  },
})

vim.o.showtabline = 2

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = refresh_colors,
})
