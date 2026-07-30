local utils = require("config.utils")
local uv = require("config.uv")
local dap = require("dap")

local function debugpy_python()
  return uv.python_interpreter(vim.fn.expand("%:p:h"))
end

dap.adapters.codelldb = {
  type = "executable",
  command = utils.mason_bin("codelldb"),
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Current file (args)",
    program = "${file}",
    args = function()
      local args_string = vim.fn.input("Arguments: ")
      return vim.split(args_string, " +")
    end,
    console = "integratedTerminal",
    cwd = function()
      return uv.project_cwd(vim.fn.expand("%:p:h"))
    end,
  },
  {
    type = "python",
    request = "launch",
    name = "Current file",
    program = "${file}",
    console = "integratedTerminal",
    cwd = function()
      return uv.project_cwd(vim.fn.expand("%:p:h"))
    end,
  },
}

dap.configurations.cpp = {
  {
    name = "Launch (codelldb)",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = function()
      return require("dap.utils").pick_process()
    end,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

require("nvim-dap-virtual-text").setup()

local dapui = require("dapui")
local function open_dapui()
  dapui.open({ reset = true })
  utils.reset_overseerlist_width()
end

dap.listeners.before.attach.dapui_config = open_dapui
dap.listeners.before.launch.dapui_config = open_dapui
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

dapui.setup({
  expand_lines = false,
  layouts = {
    {
      position = "left",
      size = 0.22,
      elements = {
        { id = "stacks", size = 0.25 },
        { id = "scopes", size = 0.45 },
        { id = "breakpoints", size = 0.15 },
        { id = "watches", size = 0.15 },
      },
    },
    {
      position = "bottom",
      size = 0.22,
      elements = {
        { id = "repl", size = 0.35 },
        { id = "console", size = 0.65 },
      },
    },
  },
})

require("dap-python").setup(debugpy_python())

local function toggle_dapui()
  dapui.toggle({ reset = true })
  utils.reset_overseerlist_width()
end

vim.keymap.set("n", "<leader>du", toggle_dapui, { desc = "DAP: Toggle UI" })
vim.keymap.set("n", "<leader>ds", dap.continue, { desc = "DAP: Start/Continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dq", dap.close, { desc = "DAP: Close session" })
vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "DAP: Restart" })
vim.keymap.set("n", "<leader>dQ", dap.terminate, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "DAP: Run to cursor" })
vim.keymap.set("n", "<leader>dR", dap.repl.toggle, { desc = "DAP: Toggle REPL" })
vim.keymap.set("n", "<leader>dh", require("dap.ui.widgets").hover, { desc = "DAP: Hover" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Conditional breakpoint" })
vim.keymap.set("n", "<leader>dD", dap.clear_breakpoints, { desc = "DAP: Clear breakpoints" })
