local pack_opts = { load = true, confirm = false }
local mini_icons = require("plugins.icons")
local I = mini_icons

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-neo-tree/neo-tree.nvim",
}, pack_opts)

require("neo-tree").setup({
  close_if_last_window = true,
  enable_git_status = true,
  sources = { "filesystem", "buffers", "git_status" },
  source_selector = {
    winbar = true,
    content_layout = "center",
    sources = {
      { source = "filesystem", display_name = "  Files" },
      { source = "buffers", display_name = "  Buffers" },
      { source = "git_status", display_name = "  Git" },
    },
  },
  default_component_configs = {
    indent = {
      padding = 0,
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      with_expanders = true,
      expander_collapsed = I.fold_close,
      expander_expanded = I.fold_open,
    },
    icon = {
      folder_closed = I.folder,
      folder_open = I.folder_open,
      folder_empty = I.folder_empty,
      default = I.file,
      provider = function(icon, node)
        local text, hl
        if node.type == "file" then
          text, hl = mini_icons.mini.get("file", node.name)
        elseif node.type == "directory" then
          text, hl = mini_icons.mini.get("directory", node.name)
          if node:is_expanded() then
            text = nil
          end
        end
        if text then
          icon.text = text
        end
        if hl then
          icon.highlight = hl
        end
      end,
    },
    git_status = {
      symbols = {
        added = I.git_add,
        deleted = I.git_delete,
        modified = I.git_change,
        renamed = I.git_rename,
        untracked = I.git_untracked,
        ignored = I.git_ignored,
        unstaged = I.git_unstaged,
        staged = I.git_staged,
        conflict = I.git_conflict,
      },
    },
    modified = { symbol = "●" },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  window = {
    width = 30,
    mappings = {
      ["<space>"] = "none",
      ["[b"] = "prev_source",
      ["]b"] = "next_source",
    },
  },
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        vim.opt_local.signcolumn = "auto"
        vim.opt_local.foldcolumn = "0"
      end,
    },
  },
})

vim.keymap.set("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>o", "<Cmd>Neotree focus<CR>", { desc = "Focus file tree" })
