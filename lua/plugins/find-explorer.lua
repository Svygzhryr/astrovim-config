-- In the file pickers (<Leader>ff, <Leader>fF, <C-p>): <C-e> shows the highlighted file in Windows
-- File Explorer. Enter still opens it in nvim as usual.
---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      actions = {
        reveal_in_explorer = function(picker, item)
          if not item then return end
          local path = vim.fs.normalize(Snacks.picker.util.path(item) or item.file):gsub("/", "\\")
          picker:close()
          -- Launch through PowerShell (a plain explorer.exe job from nvim did nothing visible), then raise
          -- the window: a process started from a terminal has no foreground rights.
          local q = function(s) return (s:gsub("'", "''")) end
          local script = ("Start-Process explorer.exe -ArgumentList '/select,\"%s\"'; Start-Sleep -Milliseconds 700; "
            .. "(New-Object -ComObject WScript.Shell).AppActivate('%s') | Out-Null"):format(
            q(path), q(vim.fn.fnamemodify(path, ":h:t")))
          local err = {}
          vim.fn.jobstart({ "powershell", "-NoProfile", "-NonInteractive", "-Command", script }, {
            stderr_buffered = true,
            on_stderr = function(_, data) err = data end,
            on_exit = function(_, code)
              local msg = vim.trim(table.concat(err, "\n"))
              if code ~= 0 or msg ~= "" then
                vim.schedule(function() vim.notify("Reveal in Explorer failed (" .. code .. "): " .. msg, vim.log.levels.ERROR) end)
              end
            end,
          })
          vim.notify("Revealed in Windows Explorer: " .. path)
        end,
      },
      sources = {
        files = {
          title = "Files  (C-e: show in Windows Explorer)",
          win = {
            input = { keys = { ["<C-e>"] = { "reveal_in_explorer", mode = { "i", "n" } } } },
            list = { keys = { ["<C-e>"] = "reveal_in_explorer" } },
          },
        },
      },
    },
  },
}
