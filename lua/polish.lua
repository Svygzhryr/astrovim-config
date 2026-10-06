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

-- Proprietary language syntax (Unbound/USS); the dir is gitignored and may be absent.
do
  local dir = vim.fn.stdpath "config" .. "/proprietary"
  if vim.uv.fs_stat(dir) then
    vim.opt.rtp:append(dir)
    dofile(dir .. "/init.lua")
  end
end

-- Restore the last session (cwd, buffers, layout) when started without file arguments.
-- AstroNvim already autosaves "Last Session" on exit; it just never loads it automatically.
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Restore last session",
  callback = function()
    if vim.fn.argc() > 0 or vim.g.started_with_stdin then return end
    -- wait for the Neo-tree startup autocmd to finish before swapping buffers/windows
    vim.defer_fn(function()
      local ok, resession = pcall(require, "resession")
      if ok then pcall(resession.load, "Last Session", { silence_errors = true }) end
    end, 150)
  end,
})

-- langmap doesn't carry through multi-key mappings (<Leader>gg etc.): after the first key the second
-- one is looked up untranslated. Mirror every <Leader> mapping with its Russian-layout spelling.
do
  local function chars(s) return vim.fn.split(s, "\\zs") end
  local ru = vim.list_extend(chars "ёйцукенгшщзхъфывапролджэячсмитьбю", chars "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ")
  local en = vim.list_extend(chars "`qwertyuiop[]asdfghjkl;'zxcvbnm,.", chars '~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')
  local to_ru = {}
  for i, e in ipairs(en) do
    to_ru[e] = ru[i]
  end

  local function translate(lhs)
    local out, i = {}, 1
    while i <= #lhs do
      local special = lhs:match("^<[^>]+>", i)
      if special then
        out[#out + 1], i = special, i + #special
      else
        local ch = vim.fn.strcharpart(lhs:sub(i), 0, 1)
        out[#out + 1], i = to_ru[ch] or ch, i + #ch
      end
    end
    return table.concat(out)
  end

  local leader = vim.g.mapleader or " "
  local function mirror(buf)
    for _, mode in ipairs { "n", "x" } do
      local maps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
      for _, m in ipairs(maps) do
        -- only <Leader> maps; the leader key itself stays as is, the rest is translated
        if m.lhs:sub(1, #leader) == leader and #m.lhs > #leader and not (m.desc or ""):find("^ru%-layout") then
          local ru_lhs = leader .. translate(m.lhs:sub(#leader + 1))
          if ru_lhs ~= m.lhs then
            local opts = { remap = true, silent = true, desc = "ru-layout " .. (m.desc or ""), buffer = buf }
            pcall(vim.keymap.set, mode, ru_lhs, m.lhs, opts)
          end
        end
      end
    end
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "LspAttach" }, {
    desc = "Mirror <Leader> maps for the Russian layout",
    callback = function(ev)
      vim.schedule(function()
        mirror()
        if vim.api.nvim_buf_is_valid(ev.buf) then mirror(ev.buf) end
      end)
    end,
  })
end
