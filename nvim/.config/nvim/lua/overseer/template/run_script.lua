return {
  name = "run script",
  condition = {
    filetype = { "sh", "python" },
  },
  params = {
    args = { optional = true, type = "list", delimiter = " " },
    cwd = {
      optional = false,
      type = "enum",
      default = vim.fn.getcwd(),
      choices = { vim.fn.getcwd(), vim.fn.expand("%:p:h") },
    },
  },
  builder = function(params)
    local args = { vim.fn.expand("%:p") }
    if params.args then
      args = vim.list_extend(args, params.args)
    end

    if vim.bo.filetype == "python" then
      local uv = require("config.uv")
      local task = uv.run_task(args[1], vim.list_slice(args, 2))
      return {
        name = vim.fn.expand("%:t"),
        cmd = task.cmd,
        args = task.args,
        cwd = params.cwd or task.cwd,
        components = {
          "display_duration",
          "on_exit_set_status",
          "on_complete_notify",
        },
      }
    end

    return {
      name = vim.fn.expand("%:t"),
      cmd = "bash",
      args = args,
      cwd = params.cwd,
      components = {
        "display_duration",
        "on_exit_set_status",
        "on_complete_notify",
      },
    }
  end,
}
