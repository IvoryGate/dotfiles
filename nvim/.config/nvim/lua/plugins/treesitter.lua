local pack_opts = { load = true, confirm = false }

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, pack_opts)

require("nvim-treesitter").setup()

local parsers = {
  "bash",
  "fish",
  "json",
  "latex",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "toml",
  "vim",
  "vimdoc",
}

local function install_parsers()
  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify(
      "tree-sitter CLI not found — run: brew install tree-sitter-cli",
      vim.log.levels.WARN
    )
    return
  end
  require("nvim-treesitter").install(parsers)
end

vim.schedule(install_parsers)

vim.api.nvim_create_autocmd("FileType", {
  pattern = parsers,
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
