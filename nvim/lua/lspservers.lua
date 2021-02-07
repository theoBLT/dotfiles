local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')
local lsp_status = require('lsp-status')
local compe = require('compe')
local snippets_nvim = require('snippets')
local lspkind = require('lspkind')

-- Capabilities
local capabilities = lsp_status.capabilities
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Completion
lspkind.init() -- setup icons

compe.setup({
  enabled = true,
  autocomplete = true,
  documentation = true,
  min_length = 1,
  source = {
    path = true,
    buffer = true,
    calc = false,
    vsnip = false,
    nvim_lsp = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    snippets_nvim = true,
    treesitter = true,
  },
})

do
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    -- local _, snippetNvim = snippets_nvim.lookup_snippet_at_cursor()

    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    -- elseif snippetNvim or snippets_nvim.has_active_snippet() then
      -- return "<cmd>lua snippets_nvim.expand_or_advance(1)<CR>"
    -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
    --   return t "<Plug>(vsnip-expand-or-jump)"
    else
      return t "<Tab>"
    end
  end

  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-p>"
    -- elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    --   return t "<Plug>(vsnip-jump-prev)"
    else
      return t "<S-Tab>"
    end
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- set logs, read with
-- :lua vim.cmd('e'..vim.lsp.get_log_path())
vim.lsp.set_log_level("debug")

-- Setup LSP statusline
lsp_status.register_progress()

-- Shared on_attach + capabilities
--
-- We set these on the `default_config` so we don't have to set up `on_attach`
-- and `capabilities` for every last LSP.
local on_attach = function(client, bufnr)
  lsp_status.on_attach(client, bufnr)
end

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  {
    capabilities = capabilities,
    on_attach = on_attach,
  }
)

-- Flow
lspconfig.flow.setup({
  cmd = { 'node_modules/.bin/flow', 'lsp' },
})

-- Lua
local sumneko_cmd

if vim.fn.executable("lua-language-server") == 1 then
  sumneko_cmd = {"lua-language-server"}
else
  local sumneko_root_path = vim.fn.getenv("HOME") .. "/.local/nvim/lsp/lua-language-server"

  sumneko_cmd = {
    sumneko_root_path .. "/bin/macOS/lua-language-server",
    "-E",
    sumneko_root_path .. "/main.lua",
  }
end

lspconfig.sumneko_lua.setup({
  cmd = sumneko_cmd,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  },
})

-- Sorbet
lspconfig.sorbet.setup({
  cmd = {
    "pay",
    "exec",
    "scripts/bin/typecheck",
    "--lsp",
    "--enable-all-experimental-lsp-features",
  },
  root_dir = util.root_pattern("sorbet", ".git"),
  settings = {},
})
