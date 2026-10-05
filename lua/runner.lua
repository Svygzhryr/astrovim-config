-- Run the current file in a terminal split, optionally on every save.
local M = {}

-- filetype -> command prefix (file path is appended, quoted)
M.cmds = {
  python = "python",
  javascript = "node",
  typescript = "npx tsx",
  lua = "nvim -l",
  sh = "bash",
  ps1 = "pwsh -NoProfile -File",
  go = "go run",
}

function M.run()
  local prefix = M.cmds[vim.bo.filetype]
  if not prefix then
    vim.notify("No runner for filetype '" .. vim.bo.filetype .. "' (edit lua/runner.lua)", vim.log.levels.WARN)
    return
  end
  local file = vim.fn.expand "%:p"
  vim.cmd "botright 12split"
  vim.cmd.terminal(('%s "%s"'):format(prefix, file))
  vim.keymap.set("n", "q", "<Cmd>bd!<CR>", { buffer = true, desc = "Close run output" })
  vim.cmd "stopinsert | wincmd p"
end

function M.toggle_on_save()
  local buf = vim.api.nvim_get_current_buf()
  local group = vim.api.nvim_create_augroup("RunOnSave" .. buf, { clear = true })
  if vim.b[buf].run_on_save then
    vim.b[buf].run_on_save = false
    vim.notify "Run-on-save: OFF"
    return
  end
  vim.b[buf].run_on_save = true
  vim.api.nvim_create_autocmd("BufWritePost", { group = group, buffer = buf, callback = M.run })
  vim.notify "Run-on-save: ON for this buffer"
end

return M
