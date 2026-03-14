# 🎶 Ambience.nvim
A lightweight Neovim plugin that plays ambient/lofi music in the background while you code. Music starts automatically when Neovim opens and stops when it closes.

## Dependencies
- [mpv](https://mpv.io/) — media player
- [socat](http://www.dest-unreach.org/socat/) — for pause/resume control

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "futurekismo-oss/ambience.nvim",
  lazy = false,
  config = function()
    require("ambience").setup({
      tracks = {
        { "Lofi Hip Hop", "https://www.youtube.com/watch?v=..." },
        { "Dark Academia", "https://www.youtube.com/watch?v=..." },
      },
    })
  end,
}
```

## Setup
```lua
require("ambience").setup({
  -- Required: list of { "name", "url" } pairs
  tracks = {
    { "Lofi Hip Hop Mix", "https://www.youtube.com/watch?v=..." },
  },
  -- Optional: delay in ms before showing track notification (default: 3000)
  delay = 3000,
  -- Optional: override default keymaps
  keymaps = {
    toggle = "<leader>at",  -- pause/resume
    stop   = "<leader>ap",  -- stop
    switch = "<leader>as",  -- open track picker
  },
})
```

## Lualine Integration
Ambience.nvim exposes a `now_playing()` function that can be used
to display the current track in your statusline.

### [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
Add the following to your lualine config:
```lua
{
  function()
    local ok, ambience = pcall(require, "ambience")
    if not ok then return "" end
    return ambience.now_playing()
  end,
}
```
This will display `🎶 Track Name` when playing and `⏸ Track Name` when paused.

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>at` | Toggle pause/resume |
| `<leader>ap` | Stop ambience |
| `<leader>as` | Open track picker |
| `<leader>ay` | Start ambience |

## Notes
- Tracks play in random order and auto-switch to a new random track when one ends
- The same track won't play twice in a row

## Credits
###### Built with assistance from [Claude Sonnet 4.6](https://claude.ai) by Anthropic.
