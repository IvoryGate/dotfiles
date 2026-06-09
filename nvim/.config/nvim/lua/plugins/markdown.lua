local pack_opts = { load = true, confirm = false }

local M = {}
local configured = false
local preview ---@type { win: snacks.win, buf: number, img: snacks.image.Placement }?
--- Markdown buffers whose inline images were cleared for zoom (must restore on close).
local zoom_hid_inline = {} ---@type table<number, boolean>

local vault_path = vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/dotfiles")

local function refresh_snacks_images(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.b[buf].snacks_image_attached then
    vim.schedule(function()
      vim.api.nvim_exec_autocmds("WinScrolled", { buffer = buf, modeline = false })
    end)
    return
  end
  require("snacks.image.doc").attach(buf)
end

--- Only clear placements; keep inline instance so we never double inline.new.
local function hide_inline_images(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  require("snacks.image.placement").clean(buf)
  zoom_hid_inline[buf] = true
end

local function restore_inline_images(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  zoom_hid_inline[buf] = nil
  refresh_snacks_images(buf)
end

---@param opts? { skip_restore?: boolean }
local function close_preview(opts)
  opts = opts or {}
  local md_buf = preview and preview.buf
  local restore = not opts.skip_restore and md_buf and zoom_hid_inline[md_buf]

  pcall(vim.api.nvim_clear_autocmds, { group = "MarkdownMediaPreview" })

  if preview then
    preview.img:close()
    preview.win:close()
    preview = nil
  end

  pcall(function()
    require("snacks.image.doc").hover_close()
  end)

  if restore and md_buf then
    zoom_hid_inline[md_buf] = nil
    vim.schedule(function()
      vim.defer_fn(function()
        restore_inline_images(md_buf)
      end, 50)
    end)
  end
end

local function text_area(win)
  win = win or vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1] or {}
  local textoff = info.textoff or 0
  return {
    width = math.max(1, vim.api.nvim_win_get_width(win) - textoff),
    col = textoff,
    height = vim.api.nvim_win_get_height(win),
  }
end

local function ensure_tmux_passthrough()
  if not vim.env.TMUX then
    return
  end
  pcall(vim.fn.system, { "tmux", "set", "-p", "allow-passthrough", "all" })
end

function M.preview_at_cursor()
  require("plugins.snacks").load()
  ensure_tmux_passthrough()
  local snacks = require("snacks")
  local doc = snacks.image.doc
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local area = text_area(win)
  local border = 1
  local pane_w = math.max(1, area.width - 2 * border)
  local pane_col = area.col
  local pane_h = math.max(12, math.min(area.height, math.floor(vim.o.lines * 0.65)))

  doc.at_cursor(function(src, pos)
    if not src then
      close_preview()
      return
    end

    -- Toggle: same image under cursor closes the zoom preview.
    if preview and preview.buf == buf and preview.img.img.src == src then
      close_preview()
      return
    end

    -- Do not restore inline yet — we open another zoom right away.
    close_preview({ skip_restore = true })

    hide_inline_images(buf)

    local preview_row = math.max(0, (pos and pos[1] or vim.api.nvim_win_get_cursor(0)[1]) - 1)
    local iw = pane_w
    local ih = pane_h
    local float = Snacks.win(Snacks.win.resolve("snacks_image_preview", {
      show = false,
      enter = false,
      relative = "win",
      anchor = "NW",
      row = preview_row,
      col = pane_col,
      width = iw,
      height = ih,
      min_width = iw,
      max_width = iw,
      min_height = 1,
      max_height = ih,
      wo = { winblend = snacks.image.terminal.env().placeholders and 0 or nil },
    }))
    float:open_buf()

    local updated = false
    local opts = {
      inline = false,
      pos = { 1, 0 },
      width = iw,
      min_width = iw,
      max_width = iw,
      max_height = ih,
      on_update_pre = function(placement)
        if updated then
          return
        end
        updated = true
        local loc = placement:state().loc
        local h = ih
        if loc.width > 0 then
          h = math.min(ih, math.max(1, math.ceil(loc.height * (iw / loc.width))))
        end
        float.opts.width = iw
        float.opts.min_width = iw
        float.opts.max_width = iw
        float.opts.height = h
        float.opts.min_height = h
        float.opts.max_height = h
        float.opts.row = preview_row
        float.opts.col = pane_col
        float:show()
        vim.schedule(function()
          placement:update()
        end)
      end,
    }

    preview = {
      win = float,
      buf = buf,
      img = snacks.image.placement.new(float.buf, src, opts),
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "VimResized" }, {
      group = vim.api.nvim_create_augroup("MarkdownMediaPreview", { clear = true }),
      buffer = buf,
      callback = function()
        if preview then
          M.preview_at_cursor()
        end
      end,
    })
  end)
end

function M.setup_buffer_maps(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "<leader>mh", M.preview_at_cursor, vim.tbl_extend("force", opts, {
    desc = "Zoom image/formula (toggle)",
  }))
  vim.keymap.set("n", "<Esc>", function()
    if preview then
      close_preview()
    end
  end, vim.tbl_extend("force", opts, { desc = "Close image zoom" }))
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
    debounce = 150,
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
    ensure_tmux_passthrough()
    M.setup_buffer_maps(args.buf)
    -- snacks.image attaches via FileType (see patch_image_doc_attach in snacks.lua)
  end,
})

vim.keymap.set("n", "<leader>mm", function()
  M.load().toggle()
end, { desc = "Toggle markdown render" })

return M
