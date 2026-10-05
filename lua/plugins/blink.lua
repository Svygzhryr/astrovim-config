-- Show the completion menu automatically in the `:` command line too
-- (AstroNvim's default only opens it on <Tab> in cmdline mode).
-- blink.cmp keeps a separate `cmdline.completion.menu.auto_show`, which is not
-- inherited from `completion.menu.auto_show`, so it has to be set explicitly.
---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = { auto_show = true },
    },
    cmdline = {
      completion = {
        menu = { auto_show = true },
      },
    },
  },
}
