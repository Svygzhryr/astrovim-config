-- In the file pickers (<Leader>ff, <Leader>fF, <C-p>): <C-e> shows the highlighted file in Windows
-- File Explorer. Enter still opens it in nvim as usual.
---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      actions = {
        reveal_in_explorer = function(picker, item)
          if not item then return end
          local path = vim.fs.normalize(Snacks.picker.util.path(item) or item.file):gsub("/", "\\")
          picker:close()
          vim.fn.jobstart({ "explorer.exe", "/select," .. path }, { detach = true })
        end,
      },
      sources = {
        files = {
          win = {
            input = { keys = { ["<C-e>"] = { "reveal_in_explorer", mode = { "i", "n" } } } },
            list = { keys = { ["<C-e>"] = "reveal_in_explorer" } },
          },
        },
      },
    },
  },
}
