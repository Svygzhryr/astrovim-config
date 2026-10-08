-- In-editor cheat sheet. Add entries to `sections` below; both views pick them up.
--   <Leader>?   fuzzy-searchable list (type to filter, e.g. "rebase", "stage", "save")
--   <Leader>f?  full page (scroll, `/` to search, `q` to close)
-- Entry format: { keys, description, "VS Code equivalent" (optional, unused now) }
-- <Leader> = Space

local M = {}

---@type { title: string, items: string[][] }[]
M.sections = {
  {
    title = "Basics",
    items = {
      { "Esc", "Back to normal mode (everything below is normal mode unless noted)" },
      { "i  a  o  O", "Insert before cursor / after cursor / new line below / new line above" },
      { "A  I", "Append at end of line / insert at start of line" },
      { ":w  :q  :wq  :q!", "Save / quit / both / quit discarding changes" },
      { "Ctrl+s", "Save (works in insert mode too)" },
      { "u  Ctrl+r", "Undo / redo" },
      { ".", "Repeat last change" },
      { "Space", "Leader key. Press it and wait: which-key lists everything" },
      { "<Leader>?  <Leader>f?", "This cheat sheet (fuzzy / full page)" },
      { "<Leader>fk", "Search ALL keymaps by name" },
    },
  },
  {
    title = "Move in a file",
    items = {
      { "h j k l", "Left / down / up / right. Fine to start with; prefer the jumps below" },
      { "w  b  e", "Next word / previous word / end of word (W B E: whitespace-separated)" },
      { "0  ^  $", "Line start / first non-blank / line end" },
      { "gg  G  42G", "File top / file bottom / line 42" },
      { "{  }", "Previous / next paragraph (blank-line block)" },
      { "%", "Jump to matching bracket" },
      { "f(  t(  ;  ,", "Jump to / just before next ( on the line; ; repeats, , reverses" },
      { "/text  n  N", "Search; next / previous match" },
      { "*  #", "Search word under cursor forward / backward" },
      { "Ctrl+o  Ctrl+i", "Jump back / forward in history. Use after every go-to-definition" },
      { "gi", "Back to where you last left insert mode" },
      { "ma  `a", "Set mark a / jump to mark a" },
    },
  },
  {
    title = "Just look around (scroll)",
    items = {
      { "mouse wheel / click", "Works as usual. Mouse is on, use it for casual reading" },
      { "Ctrl+d  Ctrl+u", "Scroll half page down / up (keyboard wheel)" },
      { "Ctrl+f  Ctrl+b", "Scroll full page down / up" },
      { "Ctrl+e  Ctrl+y", "Scroll view one line, cursor stays" },
      { "zt  zz  zb", "Put cursor line at top / center / bottom of screen" },
      { "H  M  L", "Cursor to top / middle / bottom of visible screen" },
    },
  },
  {
    title = "Edit: operator + motion",
    items = {
      { "d  c  y", "Delete / change (delete + insert) / yank (copy). Combine with a motion" },
      { "dw  cw  yw", "To start of next word. From mid-word only the rest of the word!" },
      { "diw  ciw  yiw", "Whole word under cursor, from anywhere in it" },
      { "daw", "Whole word plus trailing space" },
      { "d$  D  d0", "Delete to line end (D = same) / to line start" },
      { "dd  cc  yy", "Delete / change / copy whole line" },
      { "ci\"  ci(  ci{", "Change everything inside quotes / parens / braces (di and yi work too)" },
      { "2dw  3dd  5j", "A count goes before almost anything" },
      { "p  P", "Paste after / before cursor (system clipboard is shared)" },
      { "x  r<char>", "Delete char under cursor / replace it with <char>" },
      { "J", "Join next line onto this one" },
      { "<<  >>", "Unindent / indent line" },
      { "v  V  Ctrl+v", "Select chars / lines / block. Then d, c, y, > work on it" },
      { "<Leader>/", "Toggle comment (line or visual selection)" },
    },
  },
  {
    title = "Empty lines",
    items = {
      { "o  then Esc", "Empty line below, cursor stays on it" },
      { "O  then Esc", "Empty line above" },
      { ":put _", "Empty line below without entering insert mode (:put! _ = above)" },
      { "Enter (insert mode)", "Split line at cursor" },
    },
  },
  {
    title = "Replace",
    items = {
      { "r<char>", "Replace one character" },
      { "R", "Overwrite mode until Esc" },
      { "cw  ciw  cc", "Replace word / whole word / whole line with new text" },
      { ":s/old/new/", "Replace first match on this line (add g for all on the line)" },
      { ":%s/old/new/g", "Replace in whole file" },
      { ":%s/old/new/gc", "Same, asking to confirm each (y / n / a all / q quit)" },
      { "*  then  cgn  then  .", "Change word under cursor, then . to repeat on each next match" },
      { "<Leader>lr", "Rename symbol everywhere (LSP)" },
    },
  },
  {
    title = "Code navigation (LSP)",
    items = {
      { "gd", "Go to definition (Ctrl+o to come back)" },
      { "gr", "List references" },
      { "K", "Hover docs" },
      { "<Leader>ls", "Symbols in this file" },
      { "<Leader>la", "Code actions / quick fix" },
      { "]d  [d", "Next / previous diagnostic" },
      { "]e  [e", "Next / previous error" },
      { "<Leader>lf", "Format buffer" },
    },
  },
  {
    title = "Find files & text (picker)",
    items = {
      { "<Leader>ff  or  Ctrl+p", "Find file by name (fuzzy: plgcfg matches plugins/config.lua)" },
      { "<Leader>fw", "Search text in the whole project (live grep, needs ripgrep)" },
      { "<Leader>fb", "Open buffers" },
      { "<Leader>fo", "Recent files" },
      { "<Leader>fh", "Search Neovim help" },
      { "picker: Ctrl+n / Ctrl+p", "Move through results (or arrows); Enter opens, Esc closes" },
    },
  },
  {
    title = "Buffers, splits, explorer",
    items = {
      { "]b  [b", "Next / previous buffer" },
      { "<Leader>c", "Close buffer" },
      { "|  \\", "Vertical / horizontal split" },
      { "Ctrl+h j k l", "Move between splits / explorer" },
      { "<Leader>e", "Toggle file explorer" },
      { "<Leader>o", "Jump between explorer and editor" },
      { "explorer: a", "New file (end with / for a folder)" },
      { "explorer: r  d", "Rename / delete" },
      { "explorer: c  x  p", "Copy / cut / paste" },
      { "explorer: H  ?", "Toggle hidden files / show all explorer keys" },
    },
  },
  {
    title = "Git & terminal",
    items = {
      { "<Leader>gg", "Lazygit (full git TUI). q quits, ? shows its keys" },
      { "<Leader>gD", "Diff view of all changes (<Leader>gq closes)" },
      { "]g  [g", "Next / previous changed hunk in file" },
      { "F7", "Toggle floating terminal" },
      { "Ctrl+\\ Ctrl+n", "Leave terminal insert mode (to scroll / copy)" },
      { "Russian layout", "Works in normal mode, <Leader> maps and lazygit" },
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
