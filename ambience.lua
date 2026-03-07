local tracks = {
  { "Lofi Hip Hop Mix", "https://www.youtube.com/watch?v=_ITiwPMUzho" },
  { "Relax", "https://www.youtube.com/watch?v=f02mOEt11OQ" },
  { "Silksong", "https://www.youtube.com/watch?v=MUKm5WG25hA" },
  { "Kingdom Hearts", "https://www.youtube.com/watch?v=okpy6sDNVzI" },
  { "Hollow Knight", "https://www.youtube.com/watch?v=mYEA5A0Bjyo" },
  { "Undertale", "https://www.youtube.com/watch?v=yjU4epIX5_k" },
  { "Deltarune", "https://www.youtube.com/watch?v=V2BaYgDJrLQ" },
  { "Hollow Purple", "https://www.youtube.com/watch?v=Chhkr1DIpmQ" },
  { "Battle against a True Hero", "https://www.youtube.com/watch?v=VKh1ro20GdQ" },
  { "Hopes and Dreams", "https://www.youtube.com/watch?v=NeL0bMF1QBk" },
  { "THE HOLLOW KNIGHT", "https://www.youtube.com/watch?v=7ogpb6rc65E" }
}


local job_id = nil
local paused = false

local function start_ambience()
  -- Pick a random track from the list of tracks
  local index = math.random(#tracks)
  
  -- Get the data of the track ( name, url )
  local track = tracks[index]

  local track_name = track[1]
  local track_url = track[2]

  if not job_id then
    job_id = vim.fn.jobstart("mpv --no-video --loop --no-terminal --input-ipc-server=/tmp/ambience-socket " .. track_url)
    vim.defer_fn(function()
     vim.notify("Playing: " .. track_name, vim.log.levels.INFO, {title = "🎶 Ambience"}) 
    end, 3000)
  end
end

local function end_ambience()
  vim.fn.jobstop(job_id)
  vim.notify("Ambience stopped", vim.log.levels.INFO, {title = "🎶 Ambience"})

  job_id = nil
end

local function toggle_ambience()
  if paused then
    vim.fn.jobstart(
      'echo \'{"command": ["set_property", "pause", false]}\' | socat - /tmp/ambience-socket',
      { ["shell"] = true }
    )
    paused = false
    vim.notify("Ambience resumed", vim.log.levels.INFO, {title = "🎶 Ambience"})
  else
    vim.fn.jobstart(
      'echo \'{"command": ["set_property", "pause", true]}\' | socat - /tmp/ambience-socket',
      { ["shell"] = true }
    )
    paused = true
    vim.notify("Ambience paused", vim.log.levels.INFO, {title = "🎶 Ambience"})
  end
end

local function switch_ambience()
  end_ambience()
  -- start and stop ambience
  start_ambience()
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() start_ambience() end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function() end_ambience() end,
})

vim.keymap.set("n", "<leader>at", toggle_ambience, { desc = "Pause/Resume ambience music" })
vim.keymap.set("n", "<leader>ap", end_ambience, { desc = "Stop ambience music" })
vim.keymap.set("n", "<leader>as", switch_ambience, { desc = "switch ambience track" })

