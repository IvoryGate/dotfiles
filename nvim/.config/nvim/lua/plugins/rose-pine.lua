local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/rose-pine/neovim" }, pack_opts)

require("rose-pine").setup({
  variant = "main",
  dark_variant = "main",
  dim_inactive_windows = false,
  extend_background_behind_borders = true,
  enable = {
    terminal = true,
    legacy_highlights = true,
    migrations = true,
  },
  styles = {
    bold = true,
    italic = true,
    transparency = false,
  },
  groups = {
    background = "#191724",
    panel = "#1f1d2e",
    border = "#26233a",
    comment = "#6e6a86",
    link = "#c4a7e7",
    punctuation = "#908caa",
    error = "#eb6f92",
    hint = "#c4a7e7",
    info = "#9ccfd8",
    warn = "#f6c177",
    todo = "#31748f",
  },
  highlight_groups = {
    TabLine = { bg = "#191724", fg = "#6e6a86" },
    TabLineSel = { bg = "#26233a", fg = "#e0def4" },
    TabLineFill = { bg = "#191724" },
    WinBar = { bg = "#1f1d2e", fg = "#908caa" },
    WinBarNC = { bg = "#1f1d2e", fg = "#6e6a86" },
    StatusLine = { bg = "#191724", fg = "#e0def4" },
    StatusLineNC = { bg = "#191724", fg = "#6e6a86" },
    FloatBorder = { fg = "#26233a", bg = "#1f1d2e" },
    NormalFloat = { bg = "#1f1d2e" },
    CursorLine = { bg = "#1f1d2e" },
    SnacksDashboardHeader = { fg = "#ebbcba" },
    SnacksDashboardIcon = { fg = "#9ccfd8" },
    SnacksDashboardKey = { fg = "#c4a7e7" },
    SnacksDashboardDesc = { fg = "#e0def4" },
    SnacksDashboardFooter = { fg = "#6e6a86" },
    SnacksIndent = { fg = "#26233a" },
    SnacksIndentScope = { fg = "#31748f" },
    RenderMarkdownHeading = { fg = "#ebbcba", bold = true },
    RenderMarkdownWikiLink = { fg = "#c4a7e7", underline = true },
    RenderMarkdownLink = { fg = "#9ccfd8", underline = true },
    RenderMarkdownCode = { bg = "#1f1d2e" },
  },
})

vim.cmd.colorscheme("rose-pine")
