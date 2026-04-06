local M = {}

local defaults = {
	delay = 3000,
	tracks = {},
	keymaps = {
		toggle = "<leader>at",
		stop = "<leader>ap",
		switch = "<leader>as",
		start = "<leader>ay",
	},
}

local config = {}
local job_id = nil
local paused = false
local last_index = nil
local playlist = "/tmp/ambience-playlist.m3u"
local socketfile = "/tmp/ambience-socket"

local function write_playlist()
	local f = io.open(playlist, "w")
	for _, track in ipairs(config.tracks) do
		f:write(track[2] .. "\n")
	end
	f:close()
end

function M.start()
	if not config.tracks or #config.tracks == 0 then
		vim.notify("Please add tracks in opts", vim.log.levels.ERROR, { title = "🎶 Ambience" })
		return
	end
	write_playlist()
	job_id = vim.fn.jobstart(
		"mpv --no-video --no-terminal --loop-playlist=inf --shuffle --network-timeout=0 --input-ipc-server="
			.. socketfile
			.. " "
			.. playlist
	)
	vim.defer_fn(function()
		vim.notify("Ambience started", vim.log.levels.INFO, { title = "🎶 Ambience" })
	end, config.delay)
end

function M.stop()
	local id = job_id
	job_id = nil
	vim.fn.jobstop(id)
	vim.notify("Ambience stopped", vim.log.levels.INFO, { title = "🎶 Ambience" })
end

function M.toggle()
	if paused then
		vim.fn.jobstart(
			'echo \'{"command": ["set_property", "pause", false]}\' | socat - ' .. socketfile,
			{ shell = true }
		)
		paused = false
		vim.notify("Ambience resumed", vim.log.levels.INFO, { title = "🎶 Ambience" })
	else
		vim.fn.jobstart(
			'echo \'{"command": ["set_property", "pause", true]}\' | socat - ' .. socketfile,
			{ shell = true }
		)
		paused = true
		vim.notify("Ambience paused", vim.log.levels.INFO, { title = "🎶 Ambience" })
	end
end

function M.switch()
	local names = {}
	for _, track in ipairs(config.tracks) do
		table.insert(names, track[1])
	end
	vim.ui.select(names, { prompt = "🎶 Select track:" }, function(choice, idx)
		if not choice then
			return
		end
		last_index = idx
		local track = config.tracks[idx]
		vim.fn.jobstart(
			'echo \'{"command": ["loadfile", "' .. track[2] .. "\"]}' | socat - " .. socketfile,
			{ shell = true }
		)
		vim.notify("Playing: " .. track[1], vim.log.levels.INFO, { title = "🎶 Ambience" })
	end)
end

function M.now_playing()
	if job_id == nil then
		return ""
	end
	local result = vim.fn.system('echo \'{"command": ["get_property", "media-title"]}\' | socat - ' .. socketfile)
	local ok, data = pcall(vim.fn.json_decode, result)
	if ok and data and data.data then
		local prefix = paused and " " or "🎵 "
		return prefix .. data.data
	end
	return ""
end

function M.setup(opts)
	math.randomseed(os.time())
	config = vim.tbl_deep_extend("force", defaults, opts or {})
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			M.start()
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			M.stop()
		end,
	})
	vim.keymap.set("n", config.keymaps.toggle, M.toggle, { desc = "Pause/Resume ambience music" })
	vim.keymap.set("n", config.keymaps.stop, M.stop, { desc = "Stop ambience music" })
	vim.keymap.set("n", config.keymaps.switch, M.switch, { desc = "Open track picker" })
	vim.keymap.set("n", config.keymaps.start, M.start, { desc = "Start ambience music" })
end

return M
