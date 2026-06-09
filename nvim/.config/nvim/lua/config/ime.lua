-- Auto-switch macOS IME: English in Normal/cmdline, Chinese in Insert.
-- Requires: brew tap laishulu/homebrew && brew install macism

if vim.fn.has("mac") ~= 1 then
  return
end

local function macism_path()
  for _, path in ipairs({ "/opt/homebrew/bin/macism", "/usr/local/bin/macism" }) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return vim.fn.executable("macism") == 1 and "macism" or nil
end

local macism = macism_path()
if not macism then
  vim.g.dotfiles_ime_missing = true
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.notify(
        "macism not found — run: brew tap laishulu/homebrew && brew install macism",
        vim.log.levels.WARN,
        { title = "IME" }
      )
    end,
  })
  return
end

local ENGLISH = vim.g.dotfiles_ime_english or "com.apple.keylayout.ABC"
local CHINESE = vim.g.dotfiles_ime_chinese or "com.apple.inputmethod.SCIM.ITABC"
local insert_im = CHINESE

local function current_im()
  return vim.trim(vim.fn.system({ macism }))
end

local function switch_im(id)
  id = vim.trim(id)
  if id ~= "" then
    vim.fn.system({ macism, id })
  end
end

local function on_insert_leave()
  local cur = current_im()
  if cur ~= "" and cur ~= ENGLISH then
    insert_im = cur
    vim.g.dotfiles_ime_chinese = cur
  end
  switch_im(ENGLISH)
end

local function on_insert_enter()
  switch_im(insert_im)
end

local group = vim.api.nvim_create_augroup("DotfilesIme", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    local cur = current_im()
    if cur ~= "" and cur ~= ENGLISH then
      insert_im = cur
      vim.g.dotfiles_ime_chinese = cur
    end
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  callback = on_insert_leave,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = on_insert_enter,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = group,
  callback = function()
    switch_im(ENGLISH)
  end,
})

vim.api.nvim_create_user_command("DotfilesImeRecordChinese", function()
  local cur = current_im()
  if cur == "" or cur == ENGLISH then
    vim.notify(
      "先在系统菜单里切到「中文」输入法，再执行 :DotfilesImeRecordChinese",
      vim.log.levels.WARN,
      { title = "IME" }
    )
    return
  end
  insert_im = cur
  vim.g.dotfiles_ime_chinese = cur
  vim.notify("已记录中文输入法：" .. cur .. "\n写入 init.lua：\nvim.g.dotfiles_ime_chinese = \"" .. cur .. "\"", vim.log.levels.INFO, {
    title = "IME",
  })
end, { desc = "Record current macOS input source as Chinese (for Insert mode)" })

vim.api.nvim_create_user_command("DotfilesImeStatus", function()
  vim.notify(
    table.concat({
      "当前系统：" .. current_im(),
      "Normal 用：" .. ENGLISH,
      "Insert 用：" .. insert_im,
    }, "\n"),
    vim.log.levels.INFO,
    { title = "IME" }
  )
end, { desc = "Show IME auto-switch targets" })
