-- Show the completion menu automatically in the `:` command line too
-- (AstroNvim's default only opens it on <Tab> in cmdline mode).
---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = { auto_show = true },
    },
  },
}
