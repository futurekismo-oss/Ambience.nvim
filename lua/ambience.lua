local M = {}

local defaults = {
  delay = 3000,
  tracks = {},
  keymaps = {
    toggle = "<leader>at",
    stop   = "<leader>ap",
    switch = "<leader>as",
    start  = "<leader>ay",
  },
}

local config = {}
local job_id = nil
local paused = false
local last_index = nil
local session_id = 0

function M.start()
  if not config.tracks or #config.tracks == 0 then
    vim.notify("Please add tracks in opts", vim.log.levels.ERROR, { title = "🎶 Ambience" })
    return
  end

  local index
  repeat
    index = math.random(#config.tracks)
  until index ~= last_index or #config.tracks == 1
  last_index = index

  local track = config.tracks[index]
  local current_session = session_id

  job_id = vim.fn.jobstart(
    "mpv --no-video --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track[2],
    {
      on_exit = function()
        if current_session == session_id then
          M.start()
        end
      end,
    }
  )

  vim.defer_fn(function()
    vim.notify("Playing: " .. track[1], vim.log.levels.INFO, { title = "🎶 Ambience" })
  end, config.delay)
end

function M.stop()
  session_id = session_id + 1
  local id = job_id
  job_id = nil
  vim.fn.jobstop(id)
  vim.notify("Ambience stopped", vim.log.levels.INFO, { title = "🎶 Ambience" })
end

function M.toggle()
  if paused then
    vim.fn.jobstart(
      'echo \'{"command": ["set_property", "pause", false]}\' | socat - /tmp/ambience-socket',
      { shell = true }
    )
    paused = false
    vim.notify("Ambience resumed", vim.log.levels.INFO, { title = "🎶 Ambience" })
  else
    vim.fn.jobstart(
      'echo \'{"command": ["set_property", "pause", true]}\' | socat - /tmp/ambience-socket',
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
    if not choice then return end
    session_id = session_id + 1
    local id = job_id
    job_id = nil
    vim.fn.jobstop(id)
    local current_session = session_id
    local track = config.tracks[idx]
    last_index = idx
    job_id = vim.fn.jobstart(
      "mpv --no-video --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track[2],
      {
        on_exit = function()
          if current_session == session_id then
            M.start()
          end
        end,
      }
    )
    vim.defer_fn(function()
      vim.notify("Playing: " .. track[1], vim.log.levels.INFO, { title = "🎶 Ambience" })
    end, config.delay)
  end)
end

function M.now_playing()
  if job_id == nil then return "" end
  if paused then
    return "⏸ " .. (config.tracks[last_index] and config.tracks[last_index][1] or "")
  end
  return "🎵 " .. (config.tracks[last_index] and config.tracks[last_index][1] or "")
end

function M.setup(opts)
  math.randomseed(os.time())
  config = vim.tbl_deep_extend("force", defaults, opts or {})
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function() M.start() end,
  })
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function() M.stop() end,
  })
  vim.keymap.set("n", config.keymaps.toggle, M.toggle, { desc = "Pause/Resume ambience music" })
  vim.keymap.set("n", config.keymaps.stop,   M.stop,   { desc = "Stop ambience music" })
  vim.keymap.set("n", config.keymaps.switch, M.switch, { desc = "Open track picker" })
  vim.keymap.set("n", config.keymaps.start,  M.start,  { desc = "Start ambience music" })
end

return M
