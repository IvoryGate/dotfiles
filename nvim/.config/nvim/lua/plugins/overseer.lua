local utils = require("config.utils")
local loaded = false

local function load_overseer()
  if loaded then
    return require("overseer")
  end

  loaded = true
  vim.pack.add({
    { src = "https://github.com/stevearc/overseer.nvim" },
  }, { load = true, confirm = false })

  require("overseer").setup({
    template_timeout = 8000,
    templates = {
      "builtin",
      "python",
      "uv",
      "run_script",
    },
    task_list = {
      direction = "right",
      bindings = {
        ["o"] = false,
        ["+"] = "IncreaseDetail",
        ["_"] = "DecreaseDetail",
        ["="] = "IncreaseAllDetail",
        ["-"] = "DecreaseAllDetail",
        ["k"] = "PrevTask",
        ["j"] = "NextTask",
      },
    },
  })

  return require("overseer")
end

local function toggle_overseer()
  load_overseer()
  vim.cmd("OverseerToggle")
  utils.func_on_window("dapui_stacks", function()
    pcall(function()
      require("dapui").open({ reset = true })
    end)
  end)
end

vim.keymap.set("n", "<leader>rr", function()
  load_overseer()
  vim.cmd("OverseerRun")
end, { desc = "Run task template" })

vim.keymap.set("n", "<leader>ro", toggle_overseer, { desc = "Toggle task list" })
vim.keymap.set("n", "<leader>ra", function()
  load_overseer()
  vim.cmd("OverseerQuickAction")
end, { desc = "Overseer quick action" })

vim.keymap.set("n", "<leader>ru", function()
  local root = require("config.uv").find_root(vim.fn.expand("%:p:h"))
  if not root then
    vim.notify("No pyproject.toml found", vim.log.levels.WARN)
    return
  end
  load_overseer()
  require("overseer").new_task({
    name = "uv sync",
    cmd = "uv",
    args = { "sync" },
    cwd = root,
    components = {
      "task_list_on_start",
      "display_duration",
      "on_exit_set_status",
      "on_complete_notify",
    },
  }):start()
end, { desc = "uv sync" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "OverseerList",
  callback = function()
    vim.opt_local.winfixbuf = true
  end,
})
