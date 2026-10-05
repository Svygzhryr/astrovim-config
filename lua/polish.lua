-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Make normal/visual mode commands and mappings (incl. <Leader> ones) work
-- while the Russian (ЙЦУКЕН) keyboard layout is active.
do
  local function chars(s) return vim.fn.split(s, "\\zs") end
  local ru = vim.list_extend(chars "ёйцукенгшщзхъфывапролджэячсмитьбю", chars "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ")
  local en = vim.list_extend(chars "`qwertyuiop[]asdfghjkl;'zxcvbnm,.", chars '~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')
  local pairs_ = {}
  for i, from in ipairs(ru) do
    local to = en[i]:gsub("([,;\\])", "\\%1") -- escape langmap specials
    pairs_[#pairs_ + 1] = from .. to
  end
  vim.opt.langmap = table.concat(pairs_, ",")
end

-- Windows: when nvim is launched from Git Bash, $SHELL=/bin/bash.exe makes nvim use bash
-- with cmd-style flags (`bash /s /c ...`), so :terminal / lazygit / :! die instantly.
-- Pin cmd.exe with its matching flags.
if vim.fn.has "win32" == 1 then
  vim.o.shell = "cmd.exe"
  vim.o.shellcmdflag = "/s /c"
  vim.o.shellquote = ""
  vim.o.shellxquote = '"'
  vim.o.shellredir = ">%s 2>&1"
  vim.o.shellpipe = "2>&1| tee"
end

-- Open the file explorer on startup, keeping focus in the editor.
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open Neo-tree on startup",
  callback = function() vim.schedule(function() pcall(vim.cmd, "Neotree show") end) end,
})
