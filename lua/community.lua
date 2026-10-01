-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- colorschemes
  { import = "astrocommunity.colorscheme.monokai-pro-nvim" },
  { import = "astrocommunity.colorscheme.neofusion-nvim" },
  { import = "astrocommunity.colorscheme.oxocarbon-nvim" },
  { import = "astrocommunity.colorscheme.poimandres-nvim" },
  { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  -- oxocarbon ships a fennel rockspec that can't build on Windows; its lua is prebuilt
  { "nyoom-engineering/oxocarbon.nvim", build = false },
  -- import/override with your plugins folder
}
