local configured = false

local function load_img_clip()
  if configured then
    return require("img-clip")
  end

  configured = true
  vim.pack.add({ "https://github.com/HakonHarnes/img-clip.nvim" }, { load = true, confirm = false })

  local img_clip = require("img-clip")
  img_clip.setup({
    default = {
      dir_path = "./attachments",
      use_absolute_path = false,
      copy_images = true,
      prompt_for_file_name = false,
      file_name = "%y%m%d-%H%M%S",
      extension = "png",
      process_cmd = "magick convert - -quality 85 png:-",
      formats = { "jpeg", "jpg", "png", "gif", "webp" },
    },
    filetypes = {
      markdown = {
        template = "![image$CURSOR]($FILE_PATH)",
      },
    },
  })

  return img_clip
end

vim.keymap.set("n", "<leader>mp", function()
  load_img_clip().pasteImage()
end, { desc = "Paste image" })

return {
  load = load_img_clip,
}
