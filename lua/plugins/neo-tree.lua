-- Keep Neo-tree responsive in huge repos: git status and directory scans were blocking the UI for 5-30s.
---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- `git status` over a huge worktree is the main stall; run it async with a bounded batch size
    -- minimap is now a real split; never open files into it (caused flicker + a full-screen tree)
    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "edgy", "neominimap" },
    git_status_async = true,
    git_status_async_options = { batch_size = 1000, batch_delay = 10, max_lines = 10000 },
    -- default is `--ignored=traditional`, which makes git walk every ignored dir in the repo
    event_handlers = {
      {
        event = "before_git_status",
        handler = function(args)
          for i, a in ipairs(args.status_args) do
            if a:find("^%-%-ignored=") then args.status_args[i] = "--ignored=no" end
          end
        end,
      },
    },
    filesystem = {
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_by_name = { "node_modules", ".git", "__pycache__" },
        never_show = { ".git" },
      },
    },
  },
}
