vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
  once = true,
  callback = function()
    vim.pack.add({
      { src = "https://github.com/saghen/blink.cmp", version = "v1.8.0" },
    }, { load = true, confirm = false })

    require("blink.cmp").setup({
      completion = {
        documentation = {
          auto_show = true,
          window = {
            border = "rounded",
            scrollbar = false,
          },
        },
        menu = {
          border = "rounded",
          auto_show = true,
          auto_show_delay_ms = 0,
          scrollbar = false,
        },
      },
      signature = {
        enabled = true,
      },
      cmdline = {
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            score_offset = 1000,
            should_show_items = function(ctx)
              return ctx.trigger.initial_kind ~= "trigger_character"
            end,
          },
        },
      },
    })
  end,
})
