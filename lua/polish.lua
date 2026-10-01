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
