return {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  cmd = { 'lua-language-server' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      completion = {
        callSnippet = 'Replace',
      },
      -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}
