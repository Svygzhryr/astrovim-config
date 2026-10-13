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
          ["<Leader>gb"] = {
            function()
              -- working tree vs merge-base with the remote default branch (right side stays editable)
              local function git(...)
                local r = vim.system({ "git", ... }, { text = true }):wait()
                return r.code == 0 and vim.trim(r.stdout) or nil
              end
              local base = git("symbolic-ref", "--short", "refs/remotes/origin/HEAD")
              if not base then
                for _, b in ipairs { "origin/main", "origin/master" } do
                  if git("rev-parse", "--verify", "-q", b) then base = b break end
                end
              end
              local mb = base and git("merge-base", base, "HEAD")
              if not mb then return vim.notify("No base branch / merge-base found", vim.log.levels.WARN) end
              vim.cmd("DiffviewOpen " .. mb)
            end,
            desc = "Branch diff vs merge-base (editable)",
          },
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
