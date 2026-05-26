local mp = require("mp")

local info_overlay = mp.create_osd_overlay("ass-events")
local info_visible = false
local stats_visible = false

local function close_info()
	if not info_visible then
		return
	end
	info_visible = false
	info_overlay.data = ""
	info_overlay:update()
end

local function close_stats()
	if not stats_visible then
		return
	end
	mp.command("script-binding stats/display-stats-toggle")
	stats_visible = false
end

local function format_duration(seconds)
	local s = tonumber(seconds)
	if not s then
		return "?"
	end
	local h = math.floor(s / 3600)
	local m = math.floor(s / 60) % 60
	local sec = math.floor(s) % 60
	if h > 0 then
		return string.format("%d:%02d:%02d", h, m, sec)
	end
	return string.format("%02d:%02d", m, sec)
end

local function build_info_text()
	local filename = mp.get_property("filename") or "?"
	local width = mp.get_property("width") or "?"
	local height = mp.get_property("height") or "?"
	local vformat = mp.get_property("video-format") or "?"
	local vcodec = mp.get_property("video-codec") or "?"
	local acodec = mp.get_property("audio-codec") or "?"
	local duration = format_duration(mp.get_property("duration"))

	return string.format(
		"%s\\N%sx%s  %s  %s/%s  %s",
		filename,
		width,
		height,
		vformat,
		vcodec,
		acodec,
		duration
	)
end

local function update_info_overlay()
	if info_visible then
		info_overlay.data = string.format(
			"{\\an7\\fs15\\fnJetBrainsMono Nerd Font\\c&Hf4d6cd&\\3c&H251810&\\bord1.2\\shad0\\pos(16,16)}%s",
			build_info_text()
		)
	else
		info_overlay.data = ""
	end
	info_overlay:update()
end

local function toggle_media_info()
	if info_visible then
		close_info()
		return
	end
	close_stats()
	info_visible = true
	update_info_overlay()
end

local function toggle_stats()
	if stats_visible then
		close_stats()
		return
	end
	close_info()
	mp.command("script-binding stats/display-stats-toggle")
	stats_visible = true
end

mp.register_event("file-loaded", function()
	close_info()
	close_stats()
end)

-- mpv maps toggle-osd.lua → script id "toggle_osd" (underscore).
mp.add_key_binding(nil, "toggle-media-info", toggle_media_info, { repeatable = false })
mp.add_key_binding(nil, "toggle-stats", toggle_stats, { repeatable = false })
