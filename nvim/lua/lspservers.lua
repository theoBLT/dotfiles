local compe = require('compe')
local lsp_status = require('lsp-status')
local lspconfig = require('lspconfig')
local lspkind = require('lspkind')
local null_ls = require("null-ls")
local snippets_nvim = require('snippets')
local trouble = require('trouble')

trouble.setup({
  use_diagnostic_signs = true,
})

-- Shared on_attach + capabilities
--
-- We set these on the `default_config` so we don't have to set up `on_attach`
-- and `capabilities` for every last LSP.
local on_attach = function(client, bufnr)
  lsp_status.on_attach(client, bufnr)

  -- Floating window signature
  require('lsp_signature').on_attach({
    debug = false,
    handler_opts = {
      border = "single",
    },
  })

  -- print(vim.inspect(client.resolved_capabilities))
end

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  {
    capabilities = lsp_status.capabilities,
    on_attach = on_attach,
  }
)

-- capabilities.textDocument.completion.completionItem.snippetSupport = true

-- diagnostics setup
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = false,
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)

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
    vsnip = true,
    nvim_lsp = true,
    nvim_lua = true,
    spell = true,
    tags = true,
    snippets_nvim = true,
    treesitter = true,
    ultisnips = true,
  },
})

do
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local isAutocompleteSelected = function()
    local result = vim.fn.complete_info({'selected'})
    return result['selected'] >= 0
  end

  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    local _, snippetNvim = snippets_nvim.lookup_snippet_at_cursor()

    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif snippetNvim or snippets_nvim.has_active_snippet() then
      return "<cmd>lua return require('snippets').expand_or_advance(1)<CR>"
    elseif vim.api.nvim_eval([[ UltiSnips#CanJumpForwards() ]]) == 1 then
      return t "<cmd>call UltiSnips#JumpForwards()<CR>"
    elseif vim.fn.call("vsnip#jumpable", {1}) == 1 then
      return t "<Plug>(vsnip-jump-next)"
    else
      return t "<Tab>"
    end
  end

  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-p>"
    elseif vim.api.nvim_eval([[ UltiSnips#CanJumpBackwards() ]]) == 1 then
      return t "<cmd>call UltiSnips#JumpBackwards()<CR>"
    elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
      return t "<Plug>(vsnip-jump-prev)"
    else
      return t "<S-Tab>"
    end
  end

  _G.enter_with_snippets = function()
    local _, snippetNvim = snippets_nvim.lookup_snippet_at_cursor()
    local autocompleteOpen = vim.fn.pumvisible() == 1
    local autocompleteSelected = isAutocompleteSelected()

    if snippetNvim and not autocompleteSelected then
      if autocompleteOpen then
        vim.fn['compe#close']('<C-e>')
      end

      return t "<cmd>lua return require('snippets').expand_or_advance(1)<CR>"
    elseif vim.api.nvim_eval([[ UltiSnips#CanExpandSnippet() ]]) == 1 then
      if autocompleteOpen then
        vim.fn['compe#close']('<C-e>')
      end

      return t "<cmd>call UltiSnips#ExpandSnippet()<CR>"
    elseif vim.api.nvim_eval([[ vsnip#expandable() ]]) == 1 then
      return t "<Plug>(vsnip-expand)"
    else
      return vim.fn['compe#confirm']("\n")
    end
  end
end

vim.api.nvim_set_keymap("i", "<CR>", "v:lua.enter_with_snippets()", {expr = true, silent = true, noremap = true})
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- set logs, read with
-- :lua vim.cmd('e'..vim.lsp.get_log_path())
vim.lsp.set_log_level("debug")

-- Setup LSP statusline
lsp_status.register_progress()

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

-- Rust
lspconfig.rust_analyzer.setup({
  on_attach=on_attach,
  settings = {
    ["rust-analyzer"] = {
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      cargo = {
        loadOutDirsFromCheck = true
      },
      procMacro = {
        enable = true
      },
    }
  }
})

----------------------------------------
-- Deal with Ruby and JS specially, since we need different configs for internal
-- Stripe repos vs. vanilla Ruby/JS repos.
----------------------------------------

local noFormatting = function(client)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false
end

local function setupVanillaLspClients()
  lspconfig.flow.setup({
    on_attach = noFormatting,
  })

  lspconfig.sorbet.setup({
    on_attach = noFormatting,
    root_dir = lspconfig.util.root_pattern("sorbet", ".git"),
  })

  null_ls.register({
    -- TODO: install stylua somehow
    -- null_ls.builtins.formatting.stylua,

    -- Ruby
    null_ls.builtins.diagnostics.rubocop,
    null_ls.builtins.formatting.rubocop.with({
      args = { "--auto-correct-all", "-f", "quiet", "--stderr", "--stdin", "$FILENAME" },
    }),

    -- JavaScript, etc.
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.formatting.eslint_d,
  })
end

-- Load lsp for Stripe, if it exists
local _, stripeLsp = pcall(function()
  return require('stripe.lsp')
end)

local inStripe = stripeLsp and stripeLsp.setupClients

if inStripe then
  stripeLsp.setupClients(setupVanillaLspClients)
else
  setupVanillaLspClients()
end

-- Format on save.
null_ls.setup({
  on_attach = function(client)
    if client.resolved_capabilities.document_formatting then
      vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
  end,
})
