-- VSCode-style minimap on the right: code overview with git hunks, diagnostics, search matches.
---@type LazySpec
return {
  "Isrothy/neominimap.nvim",
  version = "v3.*.*",
  lazy = false, -- plugin lazy-loads itself; the docs recommend not lazy-loading it via lazy.nvim
  init = function()
    -- brighter, higher-contrast highlights (applied now and after any colorscheme change)
    local function highlights()
      local set = vim.api.nvim_set_hl
      set(0, "NeominimapCursorLine", { bg = "#a8693a" }) -- current position: theme orange (#cc8242) toned down
      -- git mode "line" paints a full-width background per changed row
      set(0, "NeominimapGitAddLine", { bg = "#6a8759" })
      set(0, "NeominimapGitChangeLine", { bg = "#7a9ec2" })
      set(0, "NeominimapGitDeleteLine", { bg = "#c75450" })
    end
    highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = highlights })

    vim.g.neominimap = {
      git = { enabled = true, mode = "line" },
      auto_enable = true,
      layout = "split", -- real window: reserves space instead of covering text
      split = {
        minimap_width = 14,
        fix_width = true,
        direction = "right",
      },
      float = {
        minimap_width = 14,
        window_border = "none",
      },
      click = { enabled = true, auto_switch_focus = false }, -- click on the map jumps to that line
      exclude_filetypes = { "help", "neo-tree", "toggleterm", "DiffviewFiles", "TelescopePrompt" },
      exclude_buftypes = { "nofile", "nowrite", "quickfix", "terminal", "prompt" },
    }
  end,
}
