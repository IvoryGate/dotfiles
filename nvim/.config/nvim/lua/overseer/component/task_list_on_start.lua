local window = require("overseer.window")

return {
  desc = "Open task list on task start",
  constructor = function()
    return {
      on_start = function()
        window.open({ direction = "right" })
      end,
    }
  end,
}
