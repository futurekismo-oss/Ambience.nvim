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
    switch = "<leader>as",  -- switch to random track
  },
})
```

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>at` | Toggle pause/resume |
| `<leader>ap` | Stop ambience |
| `<leader>as` | Switch to random track |

## Notes

- Tracks are played in random order and loop indefinitely
- Only one instance of mpv runs at a time across multiple Neovim windows

## Credits

###### Built with assistance from [Claude Sonnet 4.6](https://claude.ai) by Anthropic.

