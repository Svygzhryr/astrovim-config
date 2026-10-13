-- Content grep (rg) tuned for a huge repo. File-NAME search (picker.files / <C-p>) is a
-- separate source and is NOT affected: ignored-for-grep files still show up there by name.
---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          -- skip huge files (art, logs, dumps) without reading them
          args = { "--max-filesize", "2M" },
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
