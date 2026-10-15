-- Inline git blame on the cursor line, off by default (toggle: <Leader>uB).
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = false,
    current_line_blame_opts = { delay = 500, ignore_whitespace = true },
    current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",
  },
  keys = {
    { "<Leader>uB", "<Cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle inline blame" },
  },
}
