-- Content grep (rg) tuned for a huge repo. File-NAME search (picker.files / <C-p>) is a
-- separate source and is NOT affected: ignored-for-grep files still show up there by name.
---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- fuzzy matching (file names, symbols, etc.): always case-insensitive, even with capitals in the query
      matcher = { ignorecase = true, smartcase = false },
      sources = {
        grep = {
          -- snacks only *throttles* live input (200ms, fires on the first keystroke), so typing
          -- "foobar" spawns ~6 rg processes over the whole repo. Real debounce + min length instead:
          -- the finder sleeps first, and a newer keystroke aborts the coroutine before rg starts.
          finder = function(opts, ctx)
            if #ctx.filter.search < 3 then return function() end end
            local run = require("snacks.picker.source.grep").grep(opts, ctx)
            return function(cb)
              ctx.async:sleep(350)
              return run(cb)
            end
          end,
          -- skip huge files (art, logs, dumps) without reading them; cap threads so rg can't saturate the disk
          -- --ignore-case overrides snacks' default --smart-case, so capitals in the query don't make rg case-sensitive
          args = { "--max-filesize", "2M", "--threads", "4", "--ignore-case" },
          exclude = {
            "*.log", "*.log.*", "logs/",
            -- binary art / data: never useful to grep, expensive to scan
            "*.dds", "*.tga", "*.psd", "*.png", "*.jpg", "*.jpeg", "*.fbx", "*.bin",
            "*.wav", "*.ogg", "*.mp4", "*.zip", "*.pak", "*.pdb", "*.obj", "*.lib", "*.dll", "*.exe",
          },
        },
      },
    },
  },
}
