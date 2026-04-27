-- Treesitter：把常用语言放进 ensure_installed，启动时装好，避免每次打开 toml 都走 auto_install 下载

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true,
      indent = true,
      -- 已列在 ensure_installed 里的语言不应再每次打开都触发安装
      auto_install = true,
      ensure_installed = {
        "bash",
        "c",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "vim",
        "vimdoc",
        "toml",
        "json",
        "yaml",
      },
    },
  },
}
