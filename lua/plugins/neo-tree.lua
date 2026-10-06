-- Keep Neo-tree responsive in huge repos: git status and directory scans were blocking the UI for 5-30s.
---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- `git status` over a huge worktree is the main stall; run it async with a bounded batch size
    git_status_async = true,
    git_status_async_options = { batch_size = 1000, batch_delay = 10, max_lines = 10000 },
    filesystem = {
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_by_name = { "node_modules", ".git", "__pycache__" },
        never_show = { ".git" },
      },
    },
  },
}
