local lsp_group = vim.api.nvim_create_augroup("SetupLSP", {})
local lspconfig_loaded = false
local mason_loaded = false

local mason_commands = {
  { name = "Mason", nargs = 0 },
  { name = "MasonInstall", nargs = "+" },
  { name = "MasonUninstall", nargs = "+" },
  { name = "MasonUninstallAll", nargs = 0 },
  { name = "MasonUpdate", nargs = 0 },
  { name = "MasonLog", nargs = 0 },
}

local lsp_servers = {
  "bashls",
  "clangd",
  "jsonls",
  "lua_ls",
  "pyright",
}

local function ensure_mason_path()
  local mason_root = vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
  local mason_bin = vim.fs.joinpath(mason_root, "bin")
  local path_sep = vim.fn.has("win32") == 1 and ";" or ":"

  vim.env.MASON = mason_root
  if vim.env.PATH and not vim.startswith(vim.env.PATH, mason_bin .. path_sep) and vim.env.PATH ~= mason_bin then
    vim.env.PATH = mason_bin .. path_sep .. vim.env.PATH
  end
end

local function delete_mason_wrappers()
  for _, command in ipairs(mason_commands) do
    pcall(vim.api.nvim_del_user_command, command.name)
  end
end

local function load_mason()
  if mason_loaded then
    return require("mason.api.command")
  end

  delete_mason_wrappers()
  vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
  }, { load = true, confirm = false })

  ensure_mason_path()
  require("mason").setup()
  mason_loaded = true
  return require("mason.api.command")
end

local function load_lspconfig()
  if lspconfig_loaded then
    return
  end

  lspconfig_loaded = true
  vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
  }, { load = true, confirm = false })

  ensure_mason_path()
  for _, server in ipairs(lsp_servers) do
    vim.lsp.enable(server)
  end
end

for _, command in ipairs(mason_commands) do
  vim.api.nvim_create_user_command(command.name, function(opts)
    load_mason()
    vim.cmd({ cmd = command.name, args = opts.fargs, bang = opts.bang })
  end, {
    desc = "Lazy-load mason.nvim",
    nargs = command.nargs,
  })
end

ensure_mason_path()

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
  float = { source = true },
  signs = true,
})

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = lsp_group,
  once = true,
  callback = load_lspconfig,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local buf = event.buf
    local opts = { buffer = buf }

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.keymap.set("n", "<leader>li", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
      end, vim.tbl_extend("force", opts, { desc = "LSP: Toggle inlay hints" }))
    end

    if client:supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    vim.keymap.set("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = false })
    end, vim.tbl_extend("force", opts, { desc = "LSP: Format buffer" }))

    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP: Hover" }))
    vim.keymap.set("n", "gd", function()
      local params = vim.lsp.util.make_position_params(0, "utf-8")
      vim.lsp.buf_request(buf, "textDocument/definition", params, function(_, result)
        if not result or vim.tbl_isempty(result) then
          vim.notify("No definition found", vim.log.levels.INFO)
        else
          require("plugins.snacks").load().picker.lsp_definitions()
        end
      end)
    end, vim.tbl_extend("force", opts, { desc = "LSP: Goto definition" }))

    vim.keymap.set("n", "gD", function()
      local win = vim.api.nvim_get_current_win()
      local value = 8 * vim.api.nvim_win_get_width(win) - 20 * vim.api.nvim_win_get_height(win)
      if value < 0 then
        vim.cmd("split")
      else
        vim.cmd("vsplit")
      end
      vim.lsp.buf.definition()
    end, vim.tbl_extend("force", opts, { desc = "LSP: Goto definition (split)" }))

    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP: Rename" }))
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP: Code action" }))
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "LSP: Line diagnostic" }))

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = buf,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = buf,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
