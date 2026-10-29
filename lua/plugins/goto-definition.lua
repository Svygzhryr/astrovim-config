-- VSCode-style "go to definition": <F12>, Ctrl+Click, and `gd` in buffers without an LSP.
-- With an LSP attached it uses the server. Otherwise (Python/AS/Unbound have none here) it greps the
-- repo for a declaration of the word under the cursor and jumps straight to it if there is one match.
-- Jump back with <C-o>.
local function goto_definition()
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client:supports_method "textDocument/definition" then return vim.lsp.buf.definition() end
  end
  local word = vim.fn.expand "<cword>"
  if word == "" then return end
  require("snacks").picker.grep {
    title = "Definition: " .. word,
    search = "\\b(def|class|function|interface|namespace|var|const|enum|type)\\s+" .. word .. "\\b"
      .. "|^\\s*" .. word .. "\\s*(:[^=]+)?=[^=]",
    regex = true,
    live = false,
    auto_confirm = true,
  }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<F12>"] = { goto_definition, desc = "Go to definition" },
        ["gd"] = { goto_definition, desc = "Go to definition" },
        ["<C-LeftMouse>"] = {
          function()
            local pos = vim.fn.getmousepos()
            if pos.winid == 0 then return end
            vim.api.nvim_set_current_win(pos.winid)
            pcall(vim.api.nvim_win_set_cursor, pos.winid, { pos.line, pos.column - 1 })
            goto_definition()
          end,
          desc = "Go to definition (Ctrl+Click)",
        },
      },
    },
  },
}
