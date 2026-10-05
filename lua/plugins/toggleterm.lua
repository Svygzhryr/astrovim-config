-- F7 / <Leader>t{h,v,f} terminals run PowerShell 7 (posh-git + PSReadLine hints).
-- vim.o.shell stays cmd.exe (see polish.lua) so :!, lazygit and the runner keep working.
---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = { shell = "pwsh -NoLogo" },
}
