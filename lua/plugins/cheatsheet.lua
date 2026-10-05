-- Keymaps/commands for the cheat sheet, run-current-file, and VS Code-style git/diff shortcuts.
---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      commands = {
        Cheat = { function() require("cheatsheet").pick() end, desc = "Cheat sheet" },
        CheatPage = { function() require("cheatsheet").page() end, desc = "Cheat sheet (full page)" },
      },
      mappings = {
        n = {
          ["<Leader>?"] = { function() require("cheatsheet").pick() end, desc = "Cheat sheet" },
          ["<Leader>f?"] = { function() require("cheatsheet").page() end, desc = "Cheat sheet (page)" },

          ["<C-p>"] = { function() require("snacks").picker.files() end, desc = "Find files" },

          ["<Leader>r"] = { desc = "Run" },
          ["<Leader>rr"] = { function() require("runner").run() end, desc = "Run current file" },
          ["<Leader>rs"] = { function() require("runner").toggle_on_save() end, desc = "Toggle run on save" },

          ["<Leader>gD"] = { "<Cmd>DiffviewOpen<CR>", desc = "Diff view (all changes)" },
          ["<Leader>gh"] = { "<Cmd>DiffviewFileHistory %<CR>", desc = "File history" },
          ["<Leader>gH"] = { "<Cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
          ["<Leader>gq"] = { "<Cmd>DiffviewClose<CR>", desc = "Close diff view" },
        },
        i = {
          ["<C-s>"] = { "<Esc><Cmd>silent! update | redraw<CR>", desc = "Save" },
        },
      },
    },
  },
}
