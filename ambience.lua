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

local job_id = nil
local paused = false

function M.setup()
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
	vim.keymap.set("n", config.keymaps.end, M.stop, { desc = "Stop ambience music" })
	vim.keymap.set("n", config.keymaps.switch, M.switch, { desc = "switch ambience track" })
end

function M.start()
	-- Pick a random track from the list of tracks
	local index = math.random(#config.tracks)
	-- Get the data of the track ( name, url )
	local track = config.tracks[index]

	local track_name = track[1]
	local track_url = track[2]

	if not job_id then
		job_id =
			vim.fn.jobstart("mpv --no-video --loop --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track_url)
		vim.defer_fn(function()
			vim.notify("Playing: " .. track_name, vim.log.levels.INFO, { title = "🎶 Ambience" })
		end, config.delay)
	end
end

local function M.stop()
	vim.fn.jobstop(job_id)
	vim.notify("Ambience stopped", vim.log.levels.INFO, { title = "🎶 Ambience" })

	job_id = nil
end

local function M.toggle()
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

local function M.switch()
	M.stop()
	-- start and stop ambience
	M.start()
end
