local pack_opts = { load = true, confirm = false }

local M = {}
local configured = false
local preview ---@type { win: snacks.win, buf: number, img: snacks.image.Placement }?
local preview_fit ---@type snacks.image.Opts?

local vault_path = vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/dotfiles")

local function close_preview()
  preview_fit = nil
  if preview then
    preview.win:close()
    preview.img:close()
    preview = nil
  end
  pcall(function()
    require("snacks.image.doc").hover_close()
  end)
end

local function text_area(win)
  win = win or vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1] or {}
  local textoff = info.textoff or 0
  return {
    width = math.max(1, vim.api.nvim_win_get_width(win)),
    col = 0,
    height = vim.api.nvim_win_get_height(win),
  }
end

local function patch_preview_fit()
  local ok, util = pcall(require, "snacks.image.util")
  if not ok or util._preview_fill then
    return
  end
  util._preview_fill = true
  local orig_fit = util.fit
  function util.fit(file, cells, opts)
    if not (preview_fit and preview_fit._preview) then
      return orig_fit(file, cells, opts)
    end
    local target_w = preview_fit.max_width
    local target_h = preview_fit.max_height or cells.height or 9999
    local result = orig_fit(file, { width = target_w, height = target_h }, opts)
    if result.width <= 0 then
      return result
    end
    -- Width-first: always span the preview pane; height scales proportionally.
    if result.width ~= target_w then
      local scale = target_w / result.width
      return util.norm({
        width = target_w,
        height = math.max(1, math.ceil(result.height * scale)),
      })
    end
    return result
  end
end

function M.preview_at_cursor()
  require("plugins.snacks").load()
  patch_preview_fit()
  local snacks = require("snacks")
  local doc = snacks.image.doc
  local buf = vim.api.nvim_get_current_buf()
  local area = text_area()

  doc.at_cursor(function(src, pos)
    if not src then
      close_preview()
      return
    end

    if preview and preview.buf == buf and preview.img.img.src == src then
      preview.img:update()
      return
    end

    close_preview()

    local preview_row = math.max(0, (pos and pos[1] or vim.api.nvim_win_get_cursor(0)[1]) - 1)
    local max_h = math.max(1, area.height - preview_row - 1)

    local float = Snacks.win(Snacks.win.resolve("snacks_image_preview", {
      show = false,
      enter = false,
      relative = "win",
      width = area.width,
      min_width = area.width,
      max_width = area.width,
      row = preview_row,
      col = area.col,
      wo = { winblend = snacks.image.terminal.env().placeholders and 0 or nil },
    }))
    float:open_buf()

    preview_fit = {
      _preview = true,
      width = area.width,
      max_width = area.width,
      max_height = max_h,
    }

    local updated = false
    local opts = {
      _preview = true,
      width = area.width,
      min_width = area.width,
      max_width = area.width,
      max_height = max_h,
      inline = false,
      -- Must run before state(); hidden float has no wins and update() would bail early.
      on_update_pre = function(placement)
        if not updated then
          updated = true
          local loc = placement:state().loc
          float.opts.width = area.width
          float.opts.min_width = area.width
          float.opts.max_width = area.width
          float.opts.height = loc.height
          float.opts.col = area.col
          float.opts.row = preview_row
          float:show()
        end
      end,
    }

    preview = {
      win = float,
      buf = buf,
      img = snacks.image.placement.new(float.buf, src, opts),
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "CursorMoved", "ModeChanged", "BufLeave", "VimResized" }, {
      group = vim.api.nvim_create_augroup("MarkdownMediaPreview", { clear = true }),
      callback = function()
        if not preview then
          return true
        end
        M.preview_at_cursor()
        if not preview then
          return true
        end
      end,
    })
  end)
end

function M.setup_buffer_maps(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "<leader>mh", M.preview_at_cursor, vim.tbl_extend("force", opts, {
    desc = "Preview image or formula",
  }))
end

function M.load()
  if configured then
    return require("render-markdown")
  end

  configured = true
  vim.g.obsidian_default_keymap = false

  require("plugins.snacks").load()

  vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/obsidian-nvim/obsidian.nvim",
  }, pack_opts)

  require("render-markdown").setup({
    preset = "obsidian",
    file_types = { "markdown" },
    latex = {
      enabled = true,
      render_modes = { "n", "c" },
    },
    link = {
      wiki = {
        enabled = true,
        conceal_destination = true,
      },
    },
  })

  require("obsidian").setup({
    legacy_commands = false,
    frontmatter = { enabled = false },
    ui = { enable = false },
    daily_notes = { enabled = false },
    new_notes_location = "current_dir",
    picker = { name = "snacks.picker" },
    workspaces = {
      {
        name = "vault",
        path = vault_path,
      },
    },
    note_id_func = function(title)
      if title then
        return title:gsub(" ", "-"):gsub("[^%w%-]", ""):lower()
      end
      return tostring(os.time())
    end,
    callbacks = {
      enter_note = function()
        local opts = { buffer = true, silent = true }

        vim.keymap.set("n", "<leader>mb", "<cmd>Obsidian backlinks<cr>", vim.tbl_extend("force", opts, {
          desc = "Markdown backlinks",
        }))

        vim.keymap.set("n", "<leader>mc", "<cmd>Obsidian toggle_checkbox<cr>", vim.tbl_extend("force", opts, {
          desc = "Toggle markdown checkbox",
        }))

        vim.keymap.set("n", "<leader>ml", function()
          return require("obsidian.api").smart_action()
        end, vim.tbl_extend("force", opts, {
          desc = "Follow wiki link",
          expr = true,
        }))
      end,
    },
  })

  return require("render-markdown")
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownEnhance", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    M.load()
    M.setup_buffer_maps(args.buf)
    require("snacks").image.doc.attach(args.buf)
  end,
})

vim.keymap.set("n", "<leader>mm", function()
  M.load().toggle()
end, { desc = "Toggle markdown render" })

return M
