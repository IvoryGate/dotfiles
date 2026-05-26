-- Refresh bottom progress bar without polling every second (that breaks toggle OSD).
local mp = require("mp")

local function show_progress()
	mp.commandv("show-progress")
end

mp.register_event("file-loaded", show_progress)
mp.observe_property("pause", "bool", function(_, paused)
	if not paused then
		show_progress()
	end
end)
