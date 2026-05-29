local uv = require("config.uv")

return {
  name = "run python (interactive)",
  condition = {
    filetype = { "python" },
  },
  params = {
    args = { optional = true, type = "list", delimiter = " " },
    cwd = { optional = true, type = "string" },
  },
  builder = function(params)
    local script = vim.fn.expand("%:p")
    local task = uv.run_task(script, params.args or {}, { interactive = true })
    if params.cwd then
      task.cwd = params.cwd
    end
    return {
      name = vim.fn.expand("%:t"),
      cmd = task.cmd,
      args = task.args,
      cwd = task.cwd,
      components = {
        "task_list_on_start",
        "display_duration",
        "on_exit_set_status",
        "on_complete_notify",
      },
    }
  end,
}
