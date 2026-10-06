-- hide the generated Russian-layout <Leader> mirrors (see polish.lua) from the popup
---@type LazySpec
return {
  "folke/which-key.nvim",
  opts = {
    filter = function(mapping) return not (mapping.desc or ""):find("^ru%-layout") end,
  },
}
