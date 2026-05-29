local uv = require("config.uv")

return {
  root_markers = {
    "pyproject.toml",
    "uv.lock",
    ".python-version",
    "pyrightconfig.json",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFiles",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic",
      },
    },
  },
  on_init = function(client)
    local root = client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name
    if not root then
      return
    end

    if uv.venv_python(root) then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
        python = {
          analysis = {
            venvPath = root,
            venv = ".venv",
          },
        },
      })
    end
  end,
}
