vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { load = true, confirm = false })

require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
})
