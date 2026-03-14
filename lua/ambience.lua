local M = {}
local defaults = {
	delay = 3000,
	tracks = {},
	keymaps = {
		toggle = "<leader>at",
		stop = "<leader>ap",
		switch = "<leader>as",
	},
}

local config = {}
local job_id = nil
local paused = false

local last_index = nil

function M.start()
	if not config.tracks or #config.tracks == 0 then
		vim.notify("Please add tracks in opts", vim.log.levels.ERROR, { title = "🎶 Ambience" })
		return -- luacheck: ignore
	end

	-- Pick a random track from the list of tracks
	local index
	repeat
		index = math.random(#config.tracks)
	until index ~= last_index or #config.tracks == 1
	last_index = index

	-- Get the data of the track ( name, url )
	local track = config.tracks[index]

	local track_name = track[1]
	local track_url = track[2]

	job_id =
		vim.fn.jobstart("mpv --no-video --loop --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track_url)
	vim.defer_fn(function()
		vim.notify("Playing: " .. track_name, vim.log.levels.INFO, { title = "🎶 Ambience" })
	end, config.delay)
end

function M.stop()
	vim.fn.jobstop(job_id)
	vim.notify("Ambience stopped", vim.log.levels.INFO, { title = "🎶 Ambience" })

	job_id = nil
end

function M.toggle()
	if paused then
		vim.fn.jobstart(
			'echo \'{"command": ["set_property", "pause", false]}\' | socat - /tmp/ambience-socket',
			{ ["shell"] = true }
		)
		paused = false
		vim.notify("Ambience resumed", vim.log.levels.INFO, { title = "🎶 Ambience" })
	else
		vim.fn.jobstart(
			'echo \'{"command": ["set_property", "pause", true]}\' | socat - /tmp/ambience-socket',
			{ ["shell"] = true }
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
	vim.ui.select(names, { prompt = " 🎶 Select track:" }, function(choice, idx)
		if not choice then
			return
		end
		M.stop()
		local track = config.tracks[idx]
		last_index = idx
		job_id =
			vim.fn.jobstart("mpv --no-video --loop --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track[2])
		vim.defer_fn(function()
			vim.notify("Playing: " .. track[1], vim.log.levels.INFO, { title = "🎶 Ambience" })
		end, config.delay)
	end)
end

function M.now_playing()
	if job_id == nil then
		return ""
	end
	if paused then
		return " " .. (config.tracks[last_index] and config.tracks[last_index][1] or "")
	end
	return "🎵 " .. (config.tracks[last_index] and config.tracks[last_index][1] or "")
end

function M.setup(opts)
	math.randomseed(os.time())
	config = vim.tbl_deep_extend("force", defaults, opts or {})

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			M.start()
		end,
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		callback = function()
			M.stop()
		end,
	})

	vim.keymap.set("n", config.keymaps.toggle, M.toggle, { desc = "Pause/Resume ambience music" })
	vim.keymap.set("n", config.keymaps.stop, M.stop, { desc = "Stop ambience music" })
	vim.keymap.set("n", config.keymaps.switch, M.switch, { desc = "switch ambience track" })
end

return M
