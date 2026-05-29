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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SnacksMarkdown", { clear = true }),
  pattern = "markdown",
  callback = function(ev)
    require("snacks").image.doc.attach(ev.buf)
  end,
})

setup()

return M
