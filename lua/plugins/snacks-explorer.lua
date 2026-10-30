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

--- Files already committed on this branch but different from the branch it was cut from, per git root. git status
--- doesn't show them (the tree is clean after a commit), so the explorer dims every other file and folder (see `format`).
--- Base of the current branch, first match wins:
---   1. `git config branch.<name>.explorer-base` (set it with :ExplorerBase)
---   2. `git config branch.<name>.vscode-merge-base` (what VS Code records)
---   3. auto: the local branch (or the remote default branch) with the fewest commits that HEAD has and it lacks.
---      Remote branches are not scanned: with thousands of refs every `--contains` query takes ~15s.
---@type table<string, {files: table<string, true>, dirs: table<string, true>, base: string?}>
local branch_changes = {}
local detected_base = {} ---@type table<string, string|false> auto-detected base per "root:branch", once per session

local function git_async(root, args, cb)
  local cmd = vim.list_extend({ "git", "-C", root, "--no-pager", "-c", "core.quotepath=off" }, args)
  vim.system(cmd, { text = true }, vim.schedule_wrap(function(r) cb(r.code == 0 and vim.trim(r.stdout) or nil) end))
end

local function common_prefix(a, b)
  local n = 0
  while n < #a and n < #b and a:byte(n + 1) == b:byte(n + 1) do n = n + 1 end
  return n
end

---@param cb fun(base: string?)
local function detect_base(root, cur, cb)
  local key = root .. ":" .. cur
  if detected_base[key] ~= nil then return cb(detected_base[key] or nil) end
  git_async(root, { "for-each-ref", "--format=%(refname:short)", "refs/heads" }, function(out)
    git_async(root, { "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, function(default)
      local names = {}
      for n in (out or ""):gmatch "[^\n]+" do
        if n ~= cur then names[#names + 1] = n end
      end
      if default then names[#names + 1] = default end
      local pending, best, best_n = #names, nil, math.huge
      local function finish()
        detected_base[key] = best or false
        cb(best)
      end
      if pending == 0 then return finish() end
      for _, name in ipairs(names) do
        git_async(root, { "rev-list", "--count", "HEAD", "^" .. name }, function(count)
          count = tonumber(count)
          -- 0 means `name` already contains HEAD (not a base); ties go to the most similarly named branch
          if count and count > 0 and (count < best_n
            or (count == best_n and common_prefix(name, cur) > common_prefix(best, cur))) then
            best, best_n = name, count
          end
          pending = pending - 1
          if pending == 0 then finish() end
        end)
      end
    end)
  end)
end

---@param root string
---@param on_done fun()
local function refresh_branch_changes(root, on_done)
  local function diff(base)
    git_async(root, { "merge-base", base, "HEAD" }, function(mb)
      if not mb then return end
      git_async(root, { "diff", "--name-only", "--no-renames", "--diff-filter=d", mb, "HEAD" }, function(out)
        local files, dirs = {}, {} -- dirs: every directory that contains a changed file
        for rel in (out or ""):gmatch "[^\n]+" do
          local abs = root .. "/" .. rel
          files[abs] = true
          local d = vim.fs.dirname(abs)
          while #d > #root and not dirs[d] do
            dirs[d] = true
            d = vim.fs.dirname(d)
          end
        end
        branch_changes[root] = { files = files, dirs = dirs, base = base }
        on_done()
      end)
    end)
  end
  git_async(root, { "branch", "--show-current" }, function(cur)
    cur = cur or ""
    git_async(root, { "config", "--get", "branch." .. cur .. ".explorer-base" }, function(cfg)
      if cfg then return diff(cfg) end
      git_async(root, { "config", "--get", "branch." .. cur .. ".vscode-merge-base" }, function(vs)
        if vs then return diff(vs) end
        detect_base(root, cur, function(base)
          if base then return diff(base) end
          git_async(root, { "rev-parse", "--verify", "-q", "origin/main" }, function(main) diff(main and "origin/main" or "origin/master") end)
        end)
      end)
    end)
  end)
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
      local function hl()
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Added" })
        -- files untouched on this branch are dimmed: the normal text colour mixed with the background
        -- (DIM = share of the text colour; lower = grayer). Changed files keep the regular colour.
        local DIM = 0.7
        local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0x1e1e1e
        local function dim(name, source)
          local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
          if not fg then return vim.api.nvim_set_hl(0, name, { link = "Comment" }) end
          local function mix(shift)
            local f, b = bit.band(bit.rshift(fg, shift), 0xff), bit.band(bit.rshift(bg, shift), 0xff)
            return bit.lshift(math.floor(f * DIM + b * (1 - DIM) + 0.5), shift)
          end
          vim.api.nvim_set_hl(0, name, { fg = mix(16) + mix(8) + mix(0) })
        end
        -- source groups must be the base ones: snacks' own groups don't exist yet when this runs at startup
        dim("SnacksExplorerDim", "Normal")
        dim("SnacksExplorerDimDir", "Directory")
      end
      hl()

      -- :ExplorerBase [ref|-]  show / set / clear (-) the base branch used for the "differs from base" marker
      vim.api.nvim_create_user_command("ExplorerBase", function(args)
        local picker = get_explorer()
        local root = picker and picker.opts.branch_root or (explorer_root() or {}).cwd
        if not root then return vim.notify("Not in a git repo", vim.log.levels.WARN) end
        git_async(root, { "branch", "--show-current" }, function(cur)
          if not cur then return vim.notify("Detached HEAD: no branch to set a base for", vim.log.levels.WARN) end
          local key = "branch." .. cur .. ".explorer-base"
          local function reload()
            detected_base[root .. ":" .. cur] = nil
            refresh_branch_changes(root, function()
              local p = get_explorer()
              if p and not p.closed then p:find() end
              vim.notify(("Explorer base for %s: %s"):format(cur, branch_changes[root].base or "?"))
            end)
          end
          if args.args == "" then return reload() end
          git_async(root, args.args == "-" and { "config", "--unset", key } or { "config", key, args.args }, reload)
        end)
      end, {
        nargs = "?",
        desc = "Show/set/clear (-) the branch the explorer's 'differs from base' marker compares against",
        complete = function()
          local root = (explorer_root() or {}).cwd
          if not root then return {} end
          local out = vim.system({ "git", "-C", root, "for-each-ref", "--format=%(refname:short)", "refs/heads" }, { text = true }):wait()
          return vim.split(vim.trim(out.stdout or ""), "\n", { trimempty = true })
        end,
      })
      vim.api.nvim_create_autocmd("ColorScheme", { group = vim.api.nvim_create_augroup("snacks_explorer_hl", {}), callback = hl })

      -- git state is cached for 15 min and the fs watcher is off, so commits/checkouts made outside nvim
      -- (lazygit terminal, another shell) leave stale markers. Re-read git status when nvim regains focus or a
      -- terminal closes; the status runs async, so the UI doesn't block.
      vim.api.nvim_create_autocmd({ "FocusGained", "TermClose" }, {
        group = vim.api.nvim_create_augroup("snacks_explorer_git_refresh", {}),
        callback = function()
          vim.schedule(function()
            local picker = get_explorer()
            if not picker or picker.closed then return end
            require("snacks.explorer.git").refresh(picker:cwd())
            local root = picker.opts.branch_root
            if root then refresh_branch_changes(root, function() if not picker.closed then picker:find() end end) end
            picker.list:set_target()
            picker:find()
          end)
        end,
      })

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
              local root = Snacks.git.get_root(ctx.filter.cwd)
              ctx.picker.opts.branch_root = root
              if root and not branch_changes[root] then
                branch_changes[root] = { files = {}, dirs = {} } -- placeholder so only one refresh runs
                refresh_branch_changes(root, function() if not ctx.picker.closed then ctx.picker:find() end end)
              end
              if ctx.picker.opts.changed_only then return changed_finder(opts, ctx) end
              return require("snacks.picker.source.explorer").explorer(opts, ctx)
            end,
            format = function(item, picker)
              local info = branch_changes[picker.opts.branch_root or ""]
              -- dim files and folders untouched on this branch (git-status colours are left alone); `info.base`
              -- is only set once the branch diff has loaded, so nothing flashes gray while it runs
              if info and info.base and not item.status and not picker.opts.changed_only then
                if not item.dir then
                  if not info.files[item.file] then item.filename_hl = "SnacksExplorerDim" end
                elseif not info.dirs[item.file] and item.file ~= picker:cwd() then
                  -- an open folder has no status of its own: ask the tree node (status bubbles up from children)
                  local node = require("snacks.explorer.tree"):node(item.file)
                  if not (node and node.status) then item.filename_hl = "SnacksExplorerDimDir" end
                end
              end
              return Snacks.picker.format.file(item, picker)
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
