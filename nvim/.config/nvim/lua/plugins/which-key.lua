local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/folke/which-key.nvim" }, pack_opts)

require("which-key").setup({
  icons = {
    group = "",
    separator = "-",
    rules = false,
  },
  spec = {
    { "<leader>f", group = "Find" },
    { "<leader>b", group = "Buffers" },
    { "<leader>m", group = "Markdown" },
    { "<leader>mm", desc = "Toggle markdown render" },
    { "<leader>mp", desc = "Paste image" },
    { "<leader>mh", desc = "Preview image/formula" },
    { "<leader>mb", desc = "Backlinks" },
    { "<leader>mc", desc = "Toggle checkbox" },
    { "<leader>ml", desc = "Follow wiki link" },
    { "<leader>e", desc = "Toggle file tree" },
    { "<leader>o", desc = "Focus file tree" },
    { "<leader>lS", desc = "Symbols outline" },
    { "<leader>w", desc = "Save buffer" },
    { "<leader>q", desc = "Quit window" },
    { "<leader>Q", desc = "Quit all" },
    { "<leader>|", desc = "Split vertically" },
    { "<leader>\\", desc = "Split horizontally" },
    { "]", group = "Next" },
    { "[", group = "Previous" },
  },
})
