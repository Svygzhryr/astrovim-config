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

-- Proprietary language syntax (Unbound/USS); the dir is gitignored and may be absent.
do
  local dir = vim.fn.stdpath "config" .. "/proprietary"
  if vim.uv.fs_stat(dir) then
    vim.opt.rtp:append(dir)
    dofile(dir .. "/init.lua")
  end
end

-- Restore the session of the directory nvim was launched in (alpha vs beta checkouts must not mix).
-- AstroNvim autosaves a per-cwd "dirsession" on exit; "Last Session" would restore the other checkout's cwd.
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Restore session for launch directory",
  callback = function()
    if vim.fn.argc() > 0 or vim.g.started_with_stdin then return end
    -- let startup finish before swapping buffers/windows
    vim.defer_fn(function()
      local ok, resession = pcall(require, "resession")
      if ok then pcall(resession.load, vim.uv.cwd(), { dir = "dirsession", silence_errors = true }) end
    end, 150)
  end,
})

-- Terminal mode ignores 'langmap', so lazygit (a terminal buffer) receives raw Cyrillic. Translate
-- Russian-layout keys to their Latin twins, only inside lazygit terminals so shells still type Russian.
do
  local function chars(s) return vim.fn.split(s, "\\zs") end
  local ru = vim.list_extend(chars "ёйцукенгшщзхъфывапролджэячсмитьбю", chars "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ")
  local en = vim.list_extend(chars "`qwertyuiop[]asdfghjkl;'zxcvbnm,.", chars '~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>')

  vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Russian-layout keys inside lazygit",
    callback = function(ev)
      if not vim.api.nvim_buf_get_name(ev.buf):find("lazygit", 1, true) then return end
      for i, from in ipairs(ru) do
        vim.keymap.set("t", from, en[i], { buffer = ev.buf, nowait = true })
      end
    end,
  })
end

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

-- Fixed RPC pipe so external tools (lazygit) can open files as tabs in this instance.
-- Only the first Astro instance gets it; later ones fail silently.
if vim.fn.has "win32" == 1 then pcall(vim.fn.serverstart, [[\\.\pipe\astro-nvim]]) end

-- Stale .git/index.lock: background `git status` (snacks explorer, gitsigns, diffview) takes the index lock
-- just to refresh stat info, and if nvim exits/crashes mid-run the lock file is left behind.
-- Optional locks make those read-only calls skip the lock; real writes (stage, commit) still lock.
-- Inherited by every git child process, including lazygit started from a terminal in this instance.
vim.env.GIT_OPTIONAL_LOCKS = "0"

-- Diff freezes: `linematch` (AstroNvim default) aligns lines inside every hunk and can stall for seconds on
-- big diffs, in diffview and gitsigns alike. Plain histogram diff is enough.
vim.o.diffopt = vim.o.diffopt:gsub(",?linematch:%d+", "")

-- Find what is freezing the UI: `:StallProfile` starts a Lua+function profile, run it again to stop and
-- open the log (sorted by self time; the top entries are the culprits).
do
  local log = vim.fn.stdpath "cache" .. "/stall-profile.log"
  local running = false
  vim.api.nvim_create_user_command("StallProfile", function()
    if not running then
      vim.cmd("profile start " .. vim.fn.fnameescape(log))
      vim.cmd "profile func *"
      vim.cmd "profile file *"
      running = true
      vim.notify "Stall profile started - reproduce the freeze, then run :StallProfile again"
    else
      vim.cmd "profile stop"
      running = false
      vim.cmd("tabnew " .. vim.fn.fnameescape(log))
      vim.notify "Stall profile written; see 'FUNCTIONS SORTED ON SELF TIME'"
    end
  end, { desc = "Toggle the stall profiler" })
end
