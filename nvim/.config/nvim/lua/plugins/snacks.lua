local M = {}

local configured = false
local I = require("plugins.icons")

local dashboard_header = table.concat({
  "     ██████╗  ██████╗'s ██╗   ██╗██╗███╗   ███╗     ",
  "     ██╔══██╗██╔════╝   ██║   ██║██║████╗ ████║     ",
  "     ██████╔╝██║        ██║   ██║██║██╔████╔██║     ",
  "     ██╔══██╗██║        ╚██╗ ██╔╝██║██║╚██╔╝██║     ",
  "     ██████╔╝╚██████╗    ╚████╔╝ ██║██║ ╚═╝ ██║     ",
  "     ╚═════╝  ╚═════╝     ╚═══╝  ╚═╝╚═╝     ╚═╝     ",
  "",
  "         Code your dreams into reality.             ",
  "",
}, "\n")

local dashboard_locked = false

local function lock_dashboard(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "snacks_dashboard" then
    return
  end

  local win = vim.fn.bufwinid(buf)
  if win <= 0 then
    return
  end

  vim.api.nvim_win_call(win, function()
    vim.wo.scrolloff = 0
    vim.wo.sidescrolloff = 0
    pcall(vim.fn.winrestview, { topline = 1, lnum = 1, col = 0, leftcol = 0 })
  end)

  local opts = { buffer = buf, silent = true, nowait = true }
  for _, key in ipairs({
    "j",
    "k",
    "h",
    "l",
    "Up",
    "Down",
    "Left",
    "Right",
    "<C-u>",
    "<C-d>",
    "<C-f>",
    "<C-b>",
    "G",
    "gg",
    "<ScrollWheelUp>",
    "<ScrollWheelDown>",
  }) do
    pcall(vim.keymap.set, "n", key, "<Nop>", opts)
  end
end

--- tmux: ioctl often reports the outer client geometry while nvim uses pane
--- columns/lines — wrong cell_width makes kitty graphics oversized (corner crop).
--- Prevent duplicate inline.new (double images) when attach races or after zoom restore.
local function patch_image_inline_singleton()
  local inline = require("snacks.image.inline")
  if inline._dotfiles_singleton then
    return
  end
  inline._dotfiles_singleton = true
  local orig_new = inline.new
  function inline.new(buf)
    if vim.b[buf].snacks_image_inline then
      return vim.b[buf].snacks_image_inline
    end
    local self = orig_new(buf)
    vim.b[buf].snacks_image_inline = self
    return self
  end
end

--- Mutex around async terminal.detect before _attach (snacks default attach can race).
local function patch_image_doc_attach()
  local doc = require("snacks.image.doc")
  if doc._dotfiles_attach then
    return
  end
  doc._dotfiles_attach = true
  local terminal = require("snacks.image.terminal")
  function doc.attach(buf)
    if require("snacks.image").config.enabled == false then
      return
    end
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if vim.b[buf].snacks_image_attached or vim.b[buf].snacks_image_attaching then
      return
    end
    vim.b[buf].snacks_image_attaching = true
    terminal.detect(function()
      vim.b[buf].snacks_image_attaching = nil
      if vim.api.nvim_buf_is_valid(buf) and not vim.b[buf].snacks_image_attached then
        doc._attach(buf)
      end
    end)
  end
end

local function patch_image_terminal_for_tmux()
  if not vim.env.TMUX or vim.fn.has("nvim-0.10") ~= 1 then
    return
  end
  local terminal = require("snacks.image.terminal")
  if terminal._dotfiles_tmux_size then
    return
  end
  terminal._dotfiles_tmux_size = true
  local orig_size = terminal.size
  function terminal.size()
    local s = orig_size()
    local ok, px = pcall(vim.fn.getcellpixels)
    if ok and type(px) == "table" and px[1] and px[1] > 0 then
      s.cell_width = px[1]
      s.cell_height = px[2] or s.cell_height
      s.scale = math.max(1, px[1] / 8)
    end
    s.columns = vim.o.columns
    s.rows = vim.o.lines
    s.width = s.columns * s.cell_width
    s.height = s.rows * s.cell_height
    return s
  end
end

local function setup_dashboard_lock()
  if dashboard_locked then
    return
  end
  dashboard_locked = true

  local group = vim.api.nvim_create_augroup("SnacksDashboardLock", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "snacks_dashboard",
    callback = function(ev)
      vim.schedule(function()
        lock_dashboard(ev.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "SnacksDashboardUpdatePost",
    callback = function()
      vim.schedule(lock_dashboard)
    end,
  })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          lock_dashboard(buf)
        end
      end)
    end,
  })
end

local function setup()
  if configured then
    return require("snacks")
  end

  configured = true
  vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } }, { load = true, confirm = false })

  local snacks = require("snacks")
  snacks.setup({
    bigfile = { enabled = true },
    notifier = {
      icons = {
        error = I.diag_error,
        warn = I.diag_warn,
        info = I.diag_info,
        debug = I.diag_hint,
      },
    },
    statuscolumn = { enabled = true },
    indent = {
      enabled = true,
      char = "▏",
      only_scope = false,
      animate = {
        enabled = vim.fn.has("nvim-0.10") == 1,
        style = "out",
      },
      scope = {
        enabled = true,
        char = "▏",
        underline = true,
        hl = "SnacksIndentScope",
      },
    },
    picker = {
      ui_select = true,
    },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        auto_resize = true,
        max_width = 80,
        max_height = 40,
      },
      math = {
        enabled = true,
        latex = {
          -- TeX Live Basic lacks varwidth; omit it from standalone options.
          tpl = [[
\documentclass[preview,border=0pt,12pt]{standalone}
\usepackage{${packages}}
\begin{document}
${header}
{ \${font_size} \selectfont
  \color[HTML]{${color}}
${content}}
\end{document}]],
        },
      },
    },
    styles = {
      snacks_image = {
        border = "rounded",
        backdrop = false,
      },
      snacks_image_preview = {
        relative = "win",
        anchor = "NW",
        border = "rounded",
        backdrop = false,
        focusable = false,
      },
    },
    dashboard = {
      enabled = vim.fn.argc() == 0,
      width = 64,
      row = nil,
      col = nil,
      preset = {
        header = dashboard_header,
        keys = {
          { icon = I.file, key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = I.search, key = "f", desc = "Find File", action = ":lua Snacks.picker.smart()" },
          { icon = I.recent, key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = I.search, key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = I.explorer, key = "e", desc = "Explorer", action = ":Neotree toggle" },
          { icon = I.folder, key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
          { icon = I.quit, key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header", padding = { 1, 2 } },
        { section = "keys", gap = 1, padding = { 1, 0 } },
        { section = "recent_files", limit = 5, padding = { 0, 1 }, title = "Recent Files" },
      },
    },
  })

  setup_dashboard_lock()
  patch_image_terminal_for_tmux()
  patch_image_doc_attach()
  patch_image_inline_singleton()

  return snacks
end

M.load = setup

local function map(key, fn, desc)
  vim.keymap.set("n", key, fn, { desc = desc })
end

local function with_snacks(callback)
  return function(...)
    return callback(setup(), ...)
  end
end

map("<leader>ff", with_snacks(function(snacks)
  snacks.picker.smart()
end), "Find file")

map("<leader>fr", with_snacks(function(snacks)
  snacks.picker.recent()
end), "Recent files")

map("<leader>fg", with_snacks(function(snacks)
  snacks.picker.grep()
end), "Grep")

map("<leader>fb", with_snacks(function(snacks)
  snacks.picker.buffers({ sort_lastused = true })
end), "Buffers")

map("<leader>fk", with_snacks(function(snacks)
  snacks.picker.keymaps({ layout = "dropdown" })
end), "Keymaps")

map("<leader>H", with_snacks(function(snacks)
  snacks.dashboard()
end), "Home dashboard")

map("<leader>fh", with_snacks(function(snacks)
  snacks.picker.help({ layout = "dropdown" })
end), "Help")

map("<leader>fc", with_snacks(function(snacks)
  snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end), "Nvim config files")

map("<leader>fs", with_snacks(function(snacks)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentSymbolProvider then
      snacks.picker.lsp_symbols({ layout = "dropdown", tree = true })
      return
    end
  end
  snacks.picker.treesitter()
end), "Document symbols")

map("<leader>fS", with_snacks(function(snacks)
  snacks.picker.lsp_workspace_symbols()
end), "Workspace symbols")

map("grr", with_snacks(function(snacks)
  snacks.picker.lsp_references({ include_declaration = false, include_current = true })
end), "LSP references")

map("<leader>fI", with_snacks(function(snacks)
  snacks.picker.lsp_incoming_calls()
end), "Incoming calls")

map("<leader>fO", with_snacks(function(snacks)
  snacks.picker.lsp_outgoing_calls({ tree = true })
end), "Outgoing calls")

map("<leader>fT", with_snacks(function(snacks)
  snacks.picker.lsp_type_definitions()
end), "Type definitions")

map("<leader>fd", with_snacks(function(snacks)
  snacks.picker.diagnostics_buffer()
end), "Buffer diagnostics")

map("<leader>fD", with_snacks(function(snacks)
  snacks.picker.diagnostics()
end), "Project diagnostics")

map("<leader>fl", with_snacks(function(snacks)
  snacks.picker.lines()
end), "Lines in buffer")

map("<leader>fj", with_snacks(function(snacks)
  snacks.picker.jumps()
end), "Jumps")

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })

setup()

return M
