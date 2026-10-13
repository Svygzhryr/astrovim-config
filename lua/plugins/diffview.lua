-- Diffview in a huge repo: don't re-run git on every index change.
---@type LazySpec
return {
  "sindrets/diffview.nvim",
  opts = { watch_index = false },
}
