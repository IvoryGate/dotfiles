local mp = require("mp")
local utils = require("mp.utils")

local opts = {
	yazi_id = "",
	show_osd = true,
}
require("mp.options").read_options(opts, "yazi-sync")

local last_path = nil
local ready = false

local function yazi_id()
	local id = opts.yazi_id
	if id == nil or id == "" then
		id = os.getenv("YAZI_ID") or ""
	end
	return id
end

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end
	if path:match("^%a+://") and not path:match("^file://") then
		return nil
	end
	path = path:gsub("^file://", "")
	if path:sub(1, 1) ~= "/" then
		local wd = mp.get_property("working-directory") or ""
		path = utils.join_path(wd, path)
	end
	return path
end

local function sync_to_yazi()
	local id = yazi_id()
	if id == "" then
		return
	end

	local path = normalize_path(mp.get_property("path"))
	if not path or path == last_path then
		return
	end
	last_path = path

	mp.command_native({
		name = "subprocess",
		playback_only = false,
		args = { "ya", "emit-to", id, "reveal", path },
	})

	if ready and opts.show_osd then
		local name = mp.get_property("filename/no-ext") or mp.get_property("filename") or "?"
		mp.osd_message("→ " .. name, 1200)
	end
end

local function step(delta)
	if delta < 0 then
		mp.command("playlist-prev")
	else
		mp.command("playlist-next")
	end
end

mp.register_event("file-loaded", function()
	sync_to_yazi()
	ready = true
end)

mp.add_key_binding(nil, "prev", function()
	step(-1)
end)
mp.add_key_binding(nil, "next", function()
	step(1)
end)
