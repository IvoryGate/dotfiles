local M = {}

---@param start_dir? string
---@return string|nil
function M.find_root(start_dir)
  local dir = vim.fs.normalize(start_dir or vim.fn.expand("%:p:h"))
  while dir do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, "pyproject.toml")) then
      return dir
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

---@param root? string
---@return string|nil
function M.venv_python(root)
  root = root or M.find_root()
  if not root then
    return nil
  end
  local python = vim.fs.joinpath(root, ".venv/bin/python")
  if vim.uv.fs_stat(python) then
    return python
  end
  return nil
end

---@param start_dir? string
---@return boolean
function M.available(start_dir)
  return vim.fn.executable("uv") == 1 and M.find_root(start_dir) ~= nil
end

---@param start_dir? string
---@return string
function M.project_cwd(start_dir)
  return M.find_root(start_dir) or vim.fn.getcwd()
end

---@param script_path string
---@param extra_args? string[]
---@param opts? { interactive?: boolean }
---@return { cmd: string, args: string[], cwd: string }
function M.run_task(script_path, extra_args, opts)
  opts = opts or {}
  extra_args = extra_args or {}
  script_path = vim.fs.normalize(script_path)
  local root = M.find_root(vim.fs.dirname(script_path))
  local cwd = root or vim.fs.dirname(script_path)

  if root and vim.fn.executable("uv") == 1 then
    local args = { "run", "python" }
    if opts.interactive then
      table.insert(args, "-i")
    end
    table.insert(args, script_path)
    vim.list_extend(args, extra_args)
    return { cmd = "uv", args = args, cwd = root }
  end

  local args = {}
  if opts.interactive then
    table.insert(args, "-i")
  end
  table.insert(args, script_path)
  vim.list_extend(args, extra_args)
  return { cmd = "python3", args = args, cwd = cwd }
end

---@param start_dir? string
---@return string
function M.python_interpreter(start_dir)
  local venv_py = M.venv_python(M.find_root(start_dir))
  if venv_py then
    return venv_py
  end

  local mason_python = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
  if mason_python ~= "" then
    return mason_python
  end

  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python3"
end

return M
