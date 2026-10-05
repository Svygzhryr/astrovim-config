-- In-editor cheat sheet. Add entries to `sections` below; both views pick them up.
--   <Leader>?   fuzzy-searchable list (type to filter, e.g. "rebase", "stage", "save")
--   <Leader>f?  full page (scroll, `/` to search, `q` to close)
-- Entry format: { keys, description, "VS Code equivalent" (optional) }
-- <Leader> = Space

local M = {}

---@type { title: string, items: string[][] }[]
M.sections = {
  {
    title = "Start here",
    items = {
      { "Space", "Leader key. Press it and wait: which-key lists everything available", "Ctrl+Shift+P" },
      { "<Leader>fk", "Search ALL keymaps by name", "Keyboard Shortcuts" },
      { "<Leader>fc", "Search ALL commands by name", "Ctrl+Shift+P" },
      { "<Leader>?", "This cheat sheet (fuzzy)" },
      { "<Leader>f?", "This cheat sheet (full page)" },
      { "Esc", "Back to normal mode (everything below is normal mode unless noted)" },
      { ":w  :q  :wq  :q!", "Write / quit / both / quit discarding" },
    },
  },
  {
    title = "Files & navigation",
    items = {
      { "<Leader>e", "Toggle file explorer (git status shown in the tree)", "Ctrl+B" },
      { "<Leader>o", "Jump between explorer and editor", "Ctrl+Shift+E" },
      { "explorer: a", "New file (end name with / for a folder; a/b/c.txt creates dirs)", "New File" },
      { "explorer: r / d", "Rename / delete", "F2 / Del" },
      { "explorer: c / x / p", "Copy / cut / paste", "Ctrl+C / X / V" },
      { "explorer: m", "Move (type new path)", "drag & drop" },
      { "explorer: H  /  ?", "Toggle hidden files  /  show all explorer keys" },
      { "explorer: <CR>  s  S", "Open / open in vsplit / open in split" },
      { "explorer: /", "Filter tree as you type", "Ctrl+F in explorer" },
      { "<Leader>n", "New empty buffer (then :w path/name.ext)", "Ctrl+N" },
      { "<Leader>R", "Rename current file", "F2" },
      { "<Leader>ff  or  Ctrl+p", "Find file by name", "Ctrl+P" },
      { "<Leader>fw", "Grep text in project", "Ctrl+Shift+F" },
      { "<Leader>fo", "Recent files", "Ctrl+R" },
      { "<Leader>fs", "Smart find (buffers + recent + files)" },
      { "<Leader>fb", "Open buffers (tabs)", "Ctrl+Tab" },
      { "]b  [b", "Next / previous buffer", "Ctrl+PgDn / PgUp" },
      { "<Leader>c", "Close buffer", "Ctrl+W" },
      { "<Leader>bd", "Pick a buffer from the tabline to close" },
      { "|  \\", "Vertical / horizontal split", "Ctrl+\\" },
      { "Ctrl+h j k l", "Move between splits / explorer", "Ctrl+1/2/3" },
      { "gd  gr  K", "Definition / references / hover docs", "F12 / Shift+F12 / hover" },
      { "Ctrl+o  Ctrl+i", "Jump back / forward in position history", "Alt+Left / Right" },
      { "<Leader>ls", "Symbols in file", "Ctrl+Shift+O" },
      { "/text  n  N", "Search in file, next / previous match", "Ctrl+F" },
      { "<Leader>q", "Close window", "" },
    },
  },
  {
    title = "Editing, save, undo",
    items = {
      { "Ctrl+s  or  <Leader>w", "Save (Ctrl+s also works in insert mode)", "Ctrl+S" },
      { "u", "Undo", "Ctrl+Z" },
      { "Ctrl+r", "Redo", "Ctrl+Y" },
      { "<Leader>fu", "Undo history browser with diff preview (restore ANY earlier state)", "Timeline" },
      { ".", "Repeat last change" },
      { "i a o O", "Insert before / after cursor / new line below / above", "" },
      { "dd  yy  p", "Cut line / copy line / paste (system clipboard is shared)", "Ctrl+X / C / V" },
      { "ciw  ci\"  cip", "Change word / inside quotes / paragraph", "" },
      { "v  V  Ctrl+v", "Select chars / lines / block (column)", "Shift+arrows / Alt+Shift+drag" },
      { "<Leader>/", "Toggle comment (line or visual selection)", "Ctrl+/" },
      { "visual: Tab / Shift+Tab", "Indent / unindent selection", "Tab / Shift+Tab" },
      { "<<  >>", "Unindent / indent line" },
      { "*", "Search word under cursor; then n / N", "Ctrl+D (sort of)" },
      { ":%s/old/new/gc", "Replace in file with confirmation", "Ctrl+H" },
      { "<Leader>lr", "Rename symbol everywhere", "F2" },
      { "<Leader>la", "Code actions / quick fix", "Ctrl+." },
    },
  },
  {
    title = "Lint, format, run & tasks",
    items = {
      { "<Leader>lf", "Format buffer", "Shift+Alt+F" },
      { "]e  [e", "Next / previous error", "F8" },
      { "]w  [w", "Next / previous warning" },
      { "<Leader>ld  or  gl", "Show diagnostic under cursor", "hover on squiggle" },
      { "<Leader>lD", "All diagnostics list (searchable)", "Problems panel" },
      { "<Leader>ud", "Toggle diagnostics on/off" },
      { ":Mason", "Install linters / formatters / LSP servers (i to install, / to filter)", "Extensions" },
      { "<Leader>rr", "Run current file (python/node/ts/lua/sh/ps1/go) in a split", "Run Code" },
      { "<Leader>rs", "Toggle run-on-save for this buffer", "Run on Save ext." },
      { "<Leader>Mr", "Pick & run a task (npm scripts, Makefile, ...)", "Run Task" },
      { "<Leader>Mc", "Run any shell command as a task", "Terminal: Run Command" },
      { "<Leader>Mt", "Task list (output, restart, stop)", "Terminal panel" },
      { "F7", "Toggle floating terminal", "Ctrl+`" },
      { "<Leader>th  tv  tf", "Terminal horizontal / vertical / float" },
      { "Ctrl+\\ Ctrl+n", "Leave terminal insert mode (to scroll / copy)" },
      { ":!cmd", "Run a one-off shell command and show output", "" },
    },
  },
  {
    title = "Git: see & stage",
    items = {
      { "(file tree)", "Changed files are coloured / marked in the explorer automatically", "SCM decorations" },
      { "<Leader>gt", "List changed files (jump to one)", "Source Control view" },
      { "<Leader>gD", "Diff view of ALL changes: file list left, side-by-side right", "Source Control diff" },
      { "diffview: Tab / S-Tab", "Next / previous changed file" },
      { "diffview: -", "Stage / unstage file under cursor", "+ / - button" },
      { "diffview: S / U / X", "Stage all / unstage all / discard file changes" },
      { "<Leader>gq", "Close diff view" },
      { "]g  [g", "Next / previous changed hunk in file", "Alt+F5" },
      { "<Leader>gp", "Preview hunk inline", "click gutter bar" },
      { "<Leader>gs", "Stage / unstage hunk", "Stage Selected Ranges" },
      { "<Leader>gr", "Reset (discard) hunk", "Revert Selected Ranges" },
      { "<Leader>gS  gR", "Stage whole buffer / reset whole buffer" },
      { "<Leader>gd", "Diff current file vs index", "Open Changes" },
      { "<Leader>gl  gL", "Blame line / full blame", "GitLens" },
      { "<Leader>gh", "History of current file (diff per commit)", "Timeline / File History" },
      { "<Leader>gH", "History of whole repo", "Git Graph" },
      { "<Leader>gc  gC", "Commit log (repo / current file)" },
      { "<Leader>gb", "Branches picker (checkout)", "Branch picker" },
      { "<Leader>gT", "Stash list" },
    },
  },
  {
    title = "Git: commit & push",
    items = {
      { "<Leader>gg", "LAZYGIT (full TUI: stage, commit, push, branches, rebase). Needs lazygit installed", "Source Control" },
      { "<Leader>gnt", "Neogit status page (s stage, u unstage, c commit, P push, F pull, ? help)" },
      { "<Leader>gnc", "Neogit commit popup directly" },
      { "lazygit: 2 / 3 / 4", "Focus Files / Branches / Commits panel" },
      { "lazygit: Space", "Stage / unstage file (a = all)", "+" },
      { "lazygit: c", "Commit (type message, Enter)", "Ctrl+Enter" },
      { "lazygit: A", "Amend last commit with staged changes (in Commits panel)", "Amend" },
      { "lazygit: P  /  p", "Push  /  pull", "Sync" },
      { "lazygit: ?", "Show every key for the current panel" },
      { "lazygit: q", "Quit back to editor" },
    },
  },
  {
    title = "Git: REBASE (fast path = lazygit, <Leader>gg)",
    items = {
      { "ONE-TIME: install lazygit", "winget install JesseDuffield.lazygit   (or: choco install lazygit), then restart nvim" },
      { "ONE-TIME: git config", "git config --global rebase.autosquash true; pull.rebase true; rebase.autoStash true; rerere.enabled true" },
      { "lazygit: 4, then s", "Squash selected commit INTO the one below it" },
      { "lazygit: f", "Fixup (squash, discard message)" },
      { "lazygit: r  /  R", "Reword (inline) / reword in editor" },
      { "lazygit: d", "Drop commit" },
      { "lazygit: e", "Edit commit (stop there; amend; then continue)" },
      { "lazygit: Ctrl+j / Ctrl+k", "Move commit down / up (reorder)" },
      { "lazygit: v  then  s / f / d", "Range-select commits, then squash / fixup / drop all at once" },
      { "lazygit: 3, pick main, r", "Rebase current branch onto selected branch" },
      { "lazygit: F  (on a commit)", "Create `fixup!` commit from staged changes targeting that commit" },
      { "lazygit: S  (Commits panel)", "Autosquash: apply all fixup! commits above selected" },
      { "lazygit: m", "Rebase menu: continue / skip / abort" },
      { "lazygit: P after rebase", "Push; offers force push (uses --force-with-lease)" },
      { "lazygit: z  /  Ctrl+z", "Undo / redo last git action (reflog based): rebase safety net" },
      { "conflict: <Leader>gD", "Diffview lists Conflicts; open one for a 3-way merge" },
      { "conflict: ]x  [x", "Next / previous conflict marker in file" },
      { "conflict: <Leader>co / ct / cb / ca", "Take ours / theirs / base / all   (dx = delete region)" },
      { "conflict: then", "Stage the file (diffview -), then lazygit m -> continue" },
      { "neogit: r", "Rebase popup: i interactive, u upstream, e elsewhere; then c continue / s skip / a abort" },
      { "CLI (F7 terminal)", "git rebase -i HEAD~5 | git pull --rebase | git commit --fixup <sha>" },
      { "CLI: --continue|--skip|--abort", "git rebase --continue / --skip / --abort" },
      { "CLI: rebase -i todo editor (core.editor)", "(vim keys; set core.editor=nvim, see README) cw then p/r/e/s/f/d to change action; ddp to reorder; :wq to start; :cq to ABORT the rebase" },
      { "CLI: panic button", "git reflog ; git reset --hard ORIG_HEAD   (undo a finished bad rebase)" },
    },
  },
  {
    title = "Config & plugins",
    items = {
      { "~/AppData/Local/nvim-astro", "Your config. lua/plugins/*.lua = plugins; lua/cheatsheet.lua = this page" },
      { "<Leader>pS  pu  pU", "Plugins: sync / check updates / update (lazy.nvim)" },
      { ":checkhealth", "Diagnose missing tools (lazygit, git, node...)" },
      { ":Lazy", "Plugin manager UI" },
    },
  },
}

local function rows()
  local out = {}
  for _, s in ipairs(M.sections) do
    for _, it in ipairs(s.items) do
      out[#out + 1] = { section = s.title, keys = it[1], desc = it[2], vs = it[3] }
    end
  end
  return out
end

--- Fuzzy-searchable list (snacks picker). Enter just closes.
function M.pick()
  local items = {}
  for i, r in ipairs(rows()) do
    items[i] = {
      idx = i,
      text = table.concat({ r.section, r.keys, r.desc, r.vs or "" }, " "),
      row = r,
    }
  end
  Snacks.picker {
    title = "Cheat sheet (type to filter)",
    items = items,
    preview = false,
    layout = { preset = "vscode" },
    format = function(item)
      local r = item.row
      local ret = {
        { ("%-26s"):format(r.keys), "Special" },
        { r.desc, "Normal" },
      }
      if r.vs and r.vs ~= "" then ret[#ret + 1] = { "   [VS Code: " .. r.vs .. "]", "Comment" } end
      ret[#ret + 1] = { "   " .. r.section, "NonText" }
      return ret
    end,
    confirm = function(picker) picker:close() end,
  }
end

--- Full-page float. q / Esc closes; use / to search.
function M.page()
  local lines = { "# Cheat sheet   (q close, / search)", "" }
  for _, s in ipairs(M.sections) do
    lines[#lines + 1] = "## " .. s.title
    lines[#lines + 1] = ""
    for _, it in ipairs(s.items) do
      local vs = (it[3] and it[3] ~= "") and ("   _[VS Code: " .. it[3] .. "]_") or ""
      lines[#lines + 1] = ("- `%s` - %s%s"):format(it[1], it[2], vs)
    end
    lines[#lines + 1] = ""
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  local w, h = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.85)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2
  for _, k in ipairs { "q", "<Esc>" } do
    vim.keymap.set("n", k, "<Cmd>close<CR>", { buffer = buf, nowait = true })
  end
end

return M
