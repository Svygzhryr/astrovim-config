-- snacks.explorer: the file tree (<Leader>e). Replaces Neo-tree, which is still installed but no longer
-- auto-starts or has keybindings (replace_netrw = false: snacks doesn't hijack directory opens either).
--
-- git_untracked MUST stay true: snacks runs `status --ignored=matching -uno` otherwise, which git rejects
-- ("Unsupported combination of ignored and untracked-files arguments") and no markers ever show.
-- A worktree-wide `git status` is what made Neo-tree crawl in the big repo, so if this lags set git_status
-- to false. The pickers below only run git when opened.
--
-- In the explorer: `gc` toggles "changed files only" (tree of `git status` entries), `]g`/`[g` jump between changes.

--- git root for the current file (nvim is often launched in a non-git parent, e.g. Wows/alpha; repo is alpha/wows)
local function explorer_root()
  local file = vim.api.nvim_buf_get_name(0)
  local root = file ~= "" and Snacks.git.get_root(vim.fs.dirname(file)) or nil
  return root and { cwd = root } or nil
end

local function get_explorer() return Snacks.picker.get({ source = "explorer" })[1] end

local MAX_UNTRACKED = 2000 -- files listed when an untracked directory is expanded in changed-only mode

--- "Changed only" finder: same item shape as the explorer (tree items with parent/last/sort), but built from
--- `git status`, so only changed files plus their parent dirs are listed. Dirs start open, except untracked
--- dirs (git reports them as one entry), which expand lazily. `picker.opts.changed_toggled[path]` flips a dir's
--- default state (see the confirm/close actions below).
local function changed_finder(_, ctx)
  local root = Snacks.git.get_root(ctx.filter.cwd)
  if not root then return function() end end
  local toggled = ctx.picker.opts.changed_toggled or {}
  ctx.picker.opts.changed_toggled = toggled

  local entries = {}
  local run = require("snacks.picker.source.proc").proc({
    cmd = "git",
    cwd = root,
    args = { "-c", "core.quotepath=off", "--no-pager", "--no-optional-locks", "status", "--porcelain=v1", "-unormal" },
    notify = false,
    transform = function(item)
      local status, rel = item.text:match "^(..) (.+)$"
      if status then
        rel = (rel:match " %-> (.+)$" or rel):gsub('^"(.*)"$', "%1")
        entries[#entries + 1] = { status = status, rel = rel }
      end
      return false
    end,
  }, ctx)

  return function(cb)
    run(function() end)

    local top = { file = root, text = "", dir = true, open = true, type = "directory", sort = "", internal = true }
    local all, dirs = { top }, {}

    local function add(item, parent, base)
      item.parent = parent
      item.sort = parent.sort .. (item.dir and "!" or "#") .. base .. " "
      item.skip = parent.skip or not parent.open -- inside a collapsed dir: not listed
      if not item.skip then all[#all + 1] = item end
      if item.dir then dirs[item.text] = item end
      return item
    end
    local function dir_item(rel)
      if rel == "" then return top end
      if dirs[rel] then return dirs[rel] end
      local parent_rel, base = rel:match "^(.*)/([^/]+)$"
      if not parent_rel then parent_rel, base = "", rel end
      local file = root .. "/" .. rel
      return add({ file = file, text = rel, dir = true, open = not toggled[file], type = "directory" }, dir_item(parent_rel), base)
    end
    local function add_path(rel, status, untracked_dir)
      local dirname, base = rel:match "^(.*)/([^/]+)$"
      if not dirname then dirname, base = "", rel end
      local file = root .. "/" .. rel
      local item = {
        file = file, text = rel, status = status, dir = untracked_dir, type = untracked_dir and "directory" or "file",
        open = untracked_dir and toggled[file] or false, -- untracked dirs start closed
      }
      add(item, dir_item(dirname), base)
      return item
    end

    for _, e in ipairs(entries) do
      local is_dir = e.rel:sub(-1) == "/"
      local rel = e.rel:gsub("/$", "")
      local item = add_path(rel, e.status, is_dir)
      if is_dir and item.open and not item.skip then
        local files = {}
        require("snacks.picker.source.proc").proc({
          cmd = "git",
          cwd = root,
          args = { "-c", "core.quotepath=off", "--no-pager", "ls-files", "--others", "--exclude-standard", "--", rel },
          notify = false,
          transform = function(f)
            files[#files + 1] = f.text
            return false
          end,
        }, ctx)(function() end)
        for i, f in ipairs(files) do
          if i > MAX_UNTRACKED then
            vim.schedule(function() Snacks.notify.warn(("Showing first %d files of %s"):format(MAX_UNTRACKED, rel)) end)
            break
          end
          add_path(f, e.status, false)
        end
      end
    end

    table.sort(all, function(a, b) return a.sort < b.sort end)
    local last = {}
    for _, it in ipairs(all) do
      if it.parent then
        if last[it.parent] then last[it.parent].last = false end
        it.last, last[it.parent] = true, it
      end
    end
    for _, it in ipairs(all) do cb(it) end
  end
end

---@param picker snacks.Picker
---@param item snacks.picker.Item
local function toggle_changed_dir(picker, item)
  local toggled = picker.opts.changed_toggled
  toggled[item.file] = not toggled[item.file] or nil
  picker.list:set_target()
  picker:find()
end

---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    init = function()
      -- untracked files default to the dim "NonText" colour (unreadable); make them stand out like added ones
      local function hl() vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Added" }) end
      hl()
      vim.api.nvim_create_autocmd("ColorScheme", { group = vim.api.nvim_create_augroup("snacks_explorer_hl", {}), callback = hl })

      -- No wrapping in the tree. Minimal horizontal scroll, like 'sidescrolloff': keep the current position
      -- while the cursor line's name is visible, scroll right only when it isn't, and scroll left only
      -- when the line would be (almost) scrolled out of view. Moving between deep siblings never jumps.
      local KEEP = 20
      vim.api.nvim_create_autocmd({ "CursorMoved", "TextChanged", "WinScrolled" }, {
        group = vim.api.nvim_create_augroup("snacks_explorer_hscroll", {}),
        callback = function()
          if vim.bo.filetype ~= "snacks_picker_list" then return end
          local picker = get_explorer()
          local win = vim.api.nvim_get_current_win()
          if not picker or picker.list.win.win ~= win then return end
          local info = vim.fn.getwininfo(win)[1]
          local avail = info.width - info.textoff - 4 -- room for the right-aligned git/diagnostic icon
          local w = vim.fn.strdisplaywidth(vim.api.nvim_get_current_line())
          local cur = vim.fn.winsaveview().leftcol
          -- lowest scroll that shows the whole cursor line's end; highest that still shows its last KEEP columns
          local lo, hi = math.max(0, w - avail), math.max(0, w - KEEP)
          local leftcol = math.min(math.max(cur, lo), hi)
          if leftcol ~= cur then vim.fn.winrestview { leftcol = leftcol } end
        end,
      })
    end,
    opts = {
      explorer = { replace_netrw = false },
      picker = {
        icons = { git = { untracked = "+" } },
        sources = {
          explorer = {
            git_status = true,
            git_untracked = true,
            watch = false,
            finder = function(opts, ctx)
              if ctx.picker.opts.changed_only then return changed_finder(opts, ctx) end
              return require("snacks.picker.source.explorer").explorer(opts, ctx)
            end,
            actions = {
              toggle_changed_only = function(picker)
                picker.opts.changed_only = not picker.opts.changed_only
                Snacks.notify(picker.opts.changed_only and "Explorer: changed files only" or "Explorer: all files")
                picker:find()
              end,
              -- expand/collapse in changed-only mode doesn't go through the explorer's Tree, so handle it here
              explorer_confirm = function(picker, item, action)
                if picker.opts.changed_only and item and item.dir then
                  if item.file ~= picker:cwd() then toggle_changed_dir(picker, item) end
                  return
                end
                return require("snacks.explorer.actions").actions.confirm(picker, item, action)
              end,
              explorer_collapse = function(picker, item, action)
                if picker.opts.changed_only then
                  if item and item.dir and item.open and item.file ~= picker:cwd() then toggle_changed_dir(picker, item) end
                  return
                end
                return require("snacks.explorer.actions").actions.explorer_close(picker, item, action)
              end,
            },
            win = {
              list = {
                wo = { wrap = false, linebreak = false },
                keys = {
                  gc = "toggle_changed_only",
                  l = "explorer_confirm",
                  ["<CR>"] = "explorer_confirm",
                  ["<2-LeftMouse>"] = "explorer_confirm",
                  h = "explorer_collapse",
                },
              },
            },
          },
        },
      },
    },
    keys = {
      { "<Leader>fE", function() Snacks.explorer(explorer_root()) end, desc = "Snacks explorer" },
      { "<Leader>fG", function() Snacks.picker.git_status() end, desc = "Changed files (git status + diff)" },
      { "<Leader>fH", function() Snacks.picker.git_diff() end, desc = "Changed hunks (git diff)" },
    },
  },

  -- take over Neo-tree's AstroNvim keys: <Leader>e toggles, <Leader>o jumps between explorer and editor
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>e"] = {
            function()
              local picker = get_explorer()
              if picker then picker:close() else Snacks.explorer(explorer_root()) end
            end,
            desc = "Toggle Explorer",
          },
          ["<Leader>o"] = {
            function()
              local picker = get_explorer()
              if not picker then return Snacks.explorer(explorer_root()) end
              if vim.bo.filetype == "snacks_picker_list" or vim.bo.filetype == "snacks_picker_input" then
                vim.cmd "wincmd p"
              else
                picker:focus "list"
              end
            end,
            desc = "Toggle Explorer Focus",
          },
        },
      },
    },
  },
}
