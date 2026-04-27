-- 仅替换 snacks dashboard 的 ASCII header；按键、布局、配色沿用 AstroNvim / snacks 默认。

---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = table.concat({
        "                                                    ",
        "     ██████╗  ██████╗'s ██╗   ██╗██╗███╗   ███╗     ",
        "     ██╔══██╗██╔════╝   ██║   ██║██║████╗ ████║     ",
        "     ██████╔╝██║        ██║   ██║██║██╔████╔██║     ",
        "     ██╔══██╗██║        ╚██╗ ██╔╝██║██║╚██╔╝██║     ",
        "     ██████╔╝╚██████╗    ╚████╔╝ ██║██║ ╚═╝ ██║     ",
        "     ╚═════╝  ╚═════╝     ╚═══╝  ╚═╝╚═╝     ╚═╝     ",
        "                                                    ",
        "                    BC's VIM                        ",
        "         Code your dreams into reality.             ",
        "                                                    ",
      }, "\n")
      return opts
    end,
  },
}
