-- Port of the VS Code theme "Best Themes - Darcula" (lakshits11.best-themes-redefined)
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "darcula-best"

local c = {
  bg = "#242424",
  bg_hl = "#2d2d2d", -- line highlight / gutter
  bg_float = "#303030",
  bg_bar = "#3a3a3a", -- status/tab bar
  bg_sel = "#204182",
  border = "#3a3a3a",
  fg = "#cccccc",
  fg_dim = "#858585",
  comment = "#707070",
  orange = "#cc8242", -- keywords, storage, constants
  yellow = "#ffc66d", -- functions, tags
  green = "#6a8759", -- strings, doc comments
  lime = "#a5c261", -- css values
  blue = "#7a9ec2", -- numbers, type params
  teal = "#89a6af", -- types
  purple = "#9e7ba0", -- properties, fields
  cyan = "#0c7d9d",
  red = "#f44747",
  warn = "#cd9731",
  info = "#6796e6",
  hint = "#b267e6",
  add = "#487e02",
  change = "#1b81a8",
  delete = "#f14c4c",
}
c.purple = "#9e7bb0"

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local groups = {
  -- Editor UI
  Normal = { fg = c.fg, bg = c.bg },
  NormalNC = { fg = c.fg, bg = c.bg },
  NormalFloat = { fg = c.fg, bg = c.bg_float },
  FloatBorder = { fg = c.border, bg = c.bg_float },
  FloatTitle = { fg = c.yellow, bg = c.bg_float, bold = true },
  Cursor = { fg = c.bg, bg = "#aeafad" },
  CursorLine = { bg = c.bg_hl },
  CursorColumn = { bg = c.bg_hl },
  ColorColumn = { bg = c.bg_hl },
  CursorLineNr = { fg = "#c6c6c6", bold = true },
  LineNr = { fg = c.fg_dim },
  SignColumn = { bg = c.bg },
  FoldColumn = { fg = c.fg_dim, bg = c.bg },
  Folded = { fg = c.fg_dim, bg = "#2a2f3a" },
  VertSplit = { fg = c.border },
  WinSeparator = { fg = c.border },
  StatusLine = { fg = c.fg, bg = c.bg_bar },
  StatusLineNC = { fg = c.fg_dim, bg = c.bg_hl },
  TabLine = { fg = c.fg_dim, bg = c.bg_hl },
  TabLineSel = { fg = "#ffffff", bg = c.bg_bar },
  TabLineFill = { bg = c.bg_hl },
  WinBar = { fg = c.fg, bg = c.bg },
  WinBarNC = { fg = c.fg_dim, bg = c.bg },
  Visual = { bg = c.bg_sel },
  VisualNOS = { bg = c.bg_sel },
  Search = { bg = "#515c6a", fg = c.fg },
  IncSearch = { bg = c.orange, fg = c.bg },
  CurSearch = { bg = c.orange, fg = c.bg },
  Substitute = { bg = c.orange, fg = c.bg },
  MatchParen = { bg = "#3b514d", bold = true },
  Pmenu = { fg = c.fg, bg = c.bg_float },
  PmenuSel = { fg = "#ffffff", bg = c.bg_sel },
  PmenuSbar = { bg = c.bg_bar },
  PmenuThumb = { bg = c.fg_dim },
  WildMenu = { fg = "#ffffff", bg = c.bg_sel },
  NonText = { fg = "#4a4a4a" },
  Whitespace = { fg = "#3a3a3a" },
  SpecialKey = { fg = "#4a4a4a" },
  EndOfBuffer = { fg = c.bg },
  Conceal = { fg = c.fg_dim },
  Directory = { fg = c.blue },
  Title = { fg = c.orange, bold = true },
  ErrorMsg = { fg = c.red },
  WarningMsg = { fg = c.warn },
  ModeMsg = { fg = c.fg, bold = true },
  MoreMsg = { fg = c.green },
  Question = { fg = c.green },
  QuickFixLine = { bg = c.bg_sel },
  SpellBad = { sp = c.red, undercurl = true },
  SpellCap = { sp = c.warn, undercurl = true },
  SpellLocal = { sp = c.info, undercurl = true },
  SpellRare = { sp = c.hint, undercurl = true },

  -- Syntax (legacy)
  Comment = { fg = c.comment },
  Constant = { fg = c.purple },
  String = { fg = c.green },
  Character = { fg = c.green },
  Number = { fg = c.blue },
  Float = { fg = c.blue },
  Boolean = { fg = c.orange },
  Identifier = { fg = c.fg },
  Function = { fg = c.yellow },
  Statement = { fg = c.orange },
  Conditional = { fg = c.orange },
  Repeat = { fg = c.orange },
  Label = { fg = c.orange },
  Operator = { fg = c.fg },
  Keyword = { fg = c.orange },
  Exception = { fg = c.orange },
  PreProc = { fg = c.yellow },
  Include = { fg = c.orange },
  Define = { fg = c.orange },
  Macro = { fg = c.yellow },
  PreCondit = { fg = c.orange },
  Type = { fg = c.teal },
  StorageClass = { fg = c.orange },
  Structure = { fg = c.orange },
  Typedef = { fg = c.teal },
  Special = { fg = c.yellow },
  SpecialChar = { fg = c.orange },
  Tag = { fg = c.yellow },
  Delimiter = { fg = c.fg },
  SpecialComment = { fg = c.green },
  Debug = { fg = c.hint },
  Underlined = { underline = true },
  Error = { fg = c.red },
  Todo = { fg = c.bg, bg = c.yellow, bold = true },

  -- Treesitter
  ["@variable"] = { fg = c.fg },
  ["@variable.builtin"] = { fg = c.orange },
  ["@variable.parameter"] = { fg = c.fg },
  ["@variable.member"] = { fg = c.purple },
  ["@constant"] = { fg = c.purple },
  ["@constant.builtin"] = { fg = c.orange },
  ["@constant.macro"] = { fg = c.yellow },
  ["@module"] = { fg = c.fg },
  ["@label"] = { fg = c.orange },
  ["@string"] = { fg = c.green },
  ["@string.escape"] = { fg = c.orange },
  ["@string.regexp"] = { fg = c.orange },
  ["@string.special"] = { fg = c.orange },
  ["@character"] = { fg = c.green },
  ["@number"] = { fg = c.blue },
  ["@number.float"] = { fg = c.blue },
  ["@boolean"] = { fg = c.orange },
  ["@type"] = { fg = c.teal },
  ["@type.builtin"] = { fg = c.teal },
  ["@type.definition"] = { fg = c.teal },
  ["@attribute"] = { fg = c.yellow },
  ["@property"] = { fg = c.purple },
  ["@function"] = { fg = c.yellow },
  ["@function.builtin"] = { fg = c.yellow },
  ["@function.call"] = { fg = c.yellow },
  ["@function.macro"] = { fg = c.yellow },
  ["@function.method"] = { fg = c.yellow },
  ["@function.method.call"] = { fg = c.yellow },
  ["@constructor"] = { fg = c.yellow },
  ["@operator"] = { fg = c.fg },
  ["@keyword"] = { fg = c.orange },
  ["@keyword.function"] = { fg = c.orange },
  ["@keyword.return"] = { fg = c.orange },
  ["@keyword.operator"] = { fg = c.orange },
  ["@keyword.import"] = { fg = c.orange },
  ["@punctuation"] = { fg = c.fg },
  ["@punctuation.delimiter"] = { fg = c.fg },
  ["@punctuation.bracket"] = { fg = c.fg },
  ["@punctuation.special"] = { fg = c.orange },
  ["@comment"] = { fg = c.comment },
  ["@comment.documentation"] = { fg = c.green },
  ["@comment.todo"] = { fg = c.bg, bg = c.yellow, bold = true },
  ["@comment.warning"] = { fg = c.bg, bg = c.warn, bold = true },
  ["@comment.error"] = { fg = c.bg, bg = c.red, bold = true },
  ["@comment.note"] = { fg = c.bg, bg = c.info, bold = true },
  ["@tag"] = { fg = c.yellow },
  ["@tag.attribute"] = { fg = c.fg },
  ["@tag.delimiter"] = { fg = c.yellow },
  ["@markup.heading"] = { fg = c.orange, bold = true },
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },
  ["@markup.link"] = { fg = c.info },
  ["@markup.link.url"] = { fg = c.info, underline = true },
  ["@markup.raw"] = { fg = c.green },
  ["@markup.list"] = { fg = c.orange },
  ["@diff.plus"] = { fg = c.lime },
  ["@diff.minus"] = { fg = c.delete },
  ["@diff.delta"] = { fg = c.warn },
  -- CSS / JSON specifics from the VS Code theme
  ["@property.css"] = { fg = c.blue },
  ["@property.json"] = { fg = c.purple },
  ["@string.special.url"] = { fg = c.info, underline = true },

  -- LSP semantic tokens
  ["@lsp.type.class"] = { fg = c.fg },
  ["@lsp.type.interface"] = { fg = c.teal },
  ["@lsp.type.enum"] = { fg = c.teal },
  ["@lsp.type.enumMember"] = { fg = c.purple },
  ["@lsp.type.namespace"] = { fg = c.fg },
  ["@lsp.type.parameter"] = { fg = c.fg },
  ["@lsp.type.property"] = { fg = c.purple },
  ["@lsp.type.typeParameter"] = { fg = c.blue, italic = true },
  ["@lsp.type.decorator"] = { fg = c.yellow },
  ["@lsp.typemod.variable.readonly"] = { fg = c.purple },

  -- Diagnostics
  DiagnosticError = { fg = c.red },
  DiagnosticWarn = { fg = c.warn },
  DiagnosticInfo = { fg = c.info },
  DiagnosticHint = { fg = c.hint },
  DiagnosticOk = { fg = c.lime },
  DiagnosticUnderlineError = { sp = c.red, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c.warn, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
  DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
  DiagnosticVirtualTextError = { fg = c.red, bg = "#3a2525" },
  DiagnosticVirtualTextWarn = { fg = c.warn, bg = "#38301f" },
  DiagnosticVirtualTextInfo = { fg = c.info, bg = "#232c3d" },
  DiagnosticVirtualTextHint = { fg = c.hint, bg = "#2f2538" },
  LspReferenceText = { bg = "#3a3a3a" },
  LspReferenceRead = { bg = "#3a3a3a" },
  LspReferenceWrite = { bg = "#004972" },
  LspInlayHint = { fg = c.fg_dim, bg = "#2d2d2d" },
  LspCodeLens = { fg = "#999999" },

  -- Diff / git
  DiffAdd = { bg = "#2c3a1f" },
  DiffChange = { bg = "#26333d" },
  DiffDelete = { bg = "#3d2323" },
  DiffText = { bg = "#34506a" },
  Added = { fg = c.lime },
  Changed = { fg = c.change },
  Removed = { fg = c.delete },
  GitSignsAdd = { fg = c.add },
  GitSignsChange = { fg = c.change },
  GitSignsDelete = { fg = c.delete },

  -- Telescope / Snacks / fzf
  TelescopeNormal = { fg = c.fg, bg = c.bg_float },
  TelescopeBorder = { fg = c.border, bg = c.bg_float },
  TelescopeSelection = { fg = "#ffffff", bg = c.bg_sel },
  TelescopeMatching = { fg = c.orange, bold = true },
  SnacksPickerMatch = { fg = c.orange, bold = true },
  SnacksPickerDir = { fg = c.fg_dim },
  SnacksIndent = { fg = "#353535" },
  SnacksIndentScope = { fg = c.orange },

  -- Completion (nvim-cmp / blink.cmp)
  CmpItemAbbrMatch = { fg = c.orange, bold = true },
  CmpItemAbbrMatchFuzzy = { fg = c.orange, bold = true },
  CmpItemKindFunction = { fg = c.yellow },
  CmpItemKindMethod = { fg = c.yellow },
  CmpItemKindVariable = { fg = c.fg },
  CmpItemKindKeyword = { fg = c.orange },
  CmpItemKindClass = { fg = c.teal },
  CmpItemKindProperty = { fg = c.purple },
  BlinkCmpMenu = { fg = c.fg, bg = c.bg_float },
  BlinkCmpMenuSelection = { fg = "#ffffff", bg = c.bg_sel },
  BlinkCmpLabelMatch = { fg = c.orange, bold = true },

  -- Misc plugins
  NeoTreeNormal = { fg = c.fg, bg = c.bg },
  NeoTreeNormalNC = { fg = c.fg, bg = c.bg },
  NeoTreeDirectoryName = { fg = c.fg },
  NeoTreeDirectoryIcon = { fg = c.blue },
  NeoTreeRootName = { fg = c.orange, bold = true },
  WhichKey = { fg = c.yellow },
  WhichKeyDesc = { fg = c.fg },
  WhichKeyGroup = { fg = c.orange },
  WhichKeySeparator = { fg = c.fg_dim },
  IndentBlanklineChar = { fg = "#353535" },
  MiniIndentscopeSymbol = { fg = c.orange },
  FlashLabel = { fg = c.bg, bg = c.orange, bold = true },
  FlashMatch = { fg = c.fg, bg = "#515c6a" },
  FlashCurrent = { fg = c.bg, bg = c.yellow },
  LazyNormal = { fg = c.fg, bg = c.bg_float },
  MasonNormal = { fg = c.fg, bg = c.bg_float },
  NoiceCmdlinePopup = { fg = c.fg, bg = c.bg_float },
  NotifyBackground = { bg = c.bg },
  TreesitterContext = { bg = c.bg_hl },
  RenderMarkdownCode = { bg = "#2a2a2a" },
}

for group, opts in pairs(groups) do
  hl(group, opts)
end

-- Terminal colors
vim.g.terminal_color_0 = "#000000"
vim.g.terminal_color_1 = "#cd3131"
vim.g.terminal_color_2 = "#6a8759"
vim.g.terminal_color_3 = "#ffc66d"
vim.g.terminal_color_4 = "#7a9ec2"
vim.g.terminal_color_5 = "#9e7bb0"
vim.g.terminal_color_6 = "#89a6af"
vim.g.terminal_color_7 = "#cccccc"
vim.g.terminal_color_8 = "#666666"
vim.g.terminal_color_9 = "#f14c4c"
vim.g.terminal_color_10 = "#a5c261"
vim.g.terminal_color_11 = "#f5f543"
vim.g.terminal_color_12 = "#3b8eea"
vim.g.terminal_color_13 = "#d670d6"
vim.g.terminal_color_14 = "#29b8db"
vim.g.terminal_color_15 = "#e5e5e5"
