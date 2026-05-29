return {
  name = "uv sync",
  condition = {
    filetype = { "python" },
  },
  builder = function()
    local uv = require("config.uv")
    local root = uv.find_root(vim.fn.expand("%:p:h"))
    if not root then
      return nil
    end
    return {
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
    }
  end,
}
