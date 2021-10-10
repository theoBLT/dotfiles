" use vim settings, rather then vi settings (much better!).
" this must be first, because it changes other options as a side effect.
set nocompatible

" =============== character fixes ====================

scriptencoding utf-8
set encoding=utf-8

" ================ general config ====================

set backspace=indent,eol,start  "allow backspace in insert mode
set history=1000                "store lots of :cmdline history
set showcmd                     "show incomplete cmds down the bottom
set showmode                    "show current mode down the bottom
set gcr=a:blinkon0              "disable cursor blink
set visualbell                  "no sounds
set autoread                    "reload files changed outside vim
set ruler                       "show ruler
set undolevels=1000             "undo levels
set laststatus=2                "fix status bar
set guifont=Inconsolata-g\ for\ Powerline
set number

" this makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" highlight funky characters and whatnot
set list
set listchars=tab:▸\ ,trail:ـ,extends:➧,eol:¬

" stop kicking me into this mode you fucking apes
set noexrc
set noex
set nosecure

" minimum width
set winwidth=100

" Put contents of unnamed register in OS X clipboard
set clipboard=unnamed

" remap ESC to jk
" inoremap jk <esc>

"Clear current search highlight by hitting g + /
nmap <silent> g/ :nohlsearch<CR>


" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.

if has('persistent_undo')
  "silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

filetype plugin on
filetype indent on

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

set nowrap       " Don't wrap lines
set linebreak    " Wrap lines at convenient points

" ================ Scrolling ========================

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

let mapleader=","
let g:mapleader=","

" =============== mouse =====================
set mouse=n

" =============== python ====================

let g:python_host_prog = $HOME . '/.pyenv/versions/py2neovim/bin/python'
let g:python3_host_prog = $HOME . '/.pyenv/versions/py3neovim/bin/python'

" =============== node.js ===================

let g:latest_node_path = $HOME . '/.nodenv/versions/15.7.0/bin/node'
let g:node_host_prog = g:latest_node_path
let g:coc_node_path = g:latest_node_path

" ============== yank ======================

" highlights yanked text for a little extra visual feedback
" so we don't need to rely on visual mode as much, try yip or y4y
augroup highlight_yank
  if has("nvim-0.5")
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
  endif
augroup END

" ================ Editing ==========================

" color column
set colorcolumn=81

" Open splits to the right or below; more natural than the default
set splitright
set splitbelow

" Create window splits easier. The default
" way is Ctrl-w,v and Ctrl-w,s. I remap
" this to vv and ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

"make Y consistent with C and D
nnoremap Y y$
function! YRRunAfterMaps()
  nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction

" remap : to ;
nnoremap ; :

" background out of insert mode
inoremap <C-Z> <Esc><C-Z>

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

" Load aliases for :vh -> :vertical h
if exists('s:loaded_vimafter')
  silent doautocmd VimAfter VimEnter *
else
  let s:loaded_vimafter = 1
  augroup VimAfter
    autocmd!
    autocmd VimEnter * source ~/.config/nvim/aliases.vim
  augroup END
endif

" Remove arrow keys in Insert Mode
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
inoremap <Up> <Nop>

" Remove arrow keys in Normal Mode
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap <Up> <Nop>

" Remove arrow keys in Visual Mode
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>
vnoremap <Up> <Nop>

" wildignore
set wildignore+=node_modules/*,bower_components/*,vendor/bundle/*,tmp/*

" function to source a file if it exists
function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

" =============== Cursor shapes =====================

" TODO this doesn't work in neovim
let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" " block cursor for normal mode
let &t_SR = "\<esc>[3 q" " underline cursor for replace mode

" ================ Plugins ==========================

call plug#begin('~/.local/nvim/plugins')

" Core
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'Konfekt/vim-alias'
Plug 'nanotee/nvim-lua-guide'         " additional help under :h nvim-lua-guide
Plug 'liuchengxu/vim-which-key'       " context menu when hitting leader key(s)
Plug 'nvim-lua/plenary.nvim'          " useful Lua functions, e.g. like boost

" Editing
Plug 'romgrk/nvim-treesitter-context' " show function context as you scroll
Plug 'AndrewRadev/splitjoin.vim'      " split/join single line/multiline
Plug 'AndrewRadev/switch.vim'         " switch syntaxes around with `gs`
Plug 'tpope/vim-commentary'           " comment with `gcc`
Plug 'romainl/vim-cool'               " disable highlights automatically on cursor move
Plug 'tpope/vim-projectionist'        " alternate files with :AV/:AS
Plug 'kshenoy/vim-signature'          " show marks in the gutter
Plug 'itspriddle/vim-stripper'        " strip whitespace on save
Plug 'tpope/vim-surround'             " cs`' to change `` to '', etc
Plug 'milkypostman/vim-togglelist'    " <leader>q to toggle quickfix
Plug 'tpope/vim-abolish'              " snake_case -> camelCase, etc
Plug 'ggandor/lightspeed.nvim'        " successor to vim-sneak
Plug 'tpope/vim-repeat'               " remaps .
Plug 'max397574/better-escape.nvim'   " faster jk

" Files
Plug 'danro/rename.vim'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/unite.vim'

" LSP
Plug 'neovim/nvim-lspconfig'             " out of the box LSP configs for common langs
Plug 'glepnir/lspsaga.nvim'              " code action plugin
Plug 'nvim-lua/lsp-status.nvim'          " provides statusline information for LSP
Plug 'hrsh7th/nvim-compe'                " completion engine
Plug 'onsails/lspkind-nvim'              " add vscode-style icons to completion menu
Plug 'nathunsmitty/nvim-ale-diagnostic'  " route lsp diagnostics to ALE
Plug 'ray-x/lsp_signature.nvim'          " floating signature 'as you type'

" Markdown
Plug 'npxbr/glow.nvim', {'do': ':GlowInstall'}  " markdown preview with :Glow

" Ruby
Plug 'keith/rspec.vim'                    " better RSpec syntax highlighting
Plug 'jgdavey/vim-blockle'                " toggle block styles with ,b
Plug 'tpope/vim-rake'                     " allow for alternate files
Plug 'vim-ruby/vim-ruby'                  " indentation, etc
Plug 'joker1007/vim-ruby-heredoc-syntax'  " fenced syntax colors in heredocs
Plug 'ecomba/vim-ruby-refactoring'        " extract vars, methods, etc

" Snippets
Plug 'norcalli/snippets.nvim'
Plug 'SirVer/UltiSnips'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

Plug 'honza/vim-snippets'
Plug 'craigmac/vim-vsnip-snippets'

" Syntax checking
Plug 'dense-analysis/ale'

" Tests
Plug 'janko-m/vim-test'

" Writing
Plug 'junegunn/goyo.vim'       " distraction-free writing with :Goyo
Plug 'junegunn/limelight.vim'  " dim other paragraphs while writing

" Theming
Plug 'chrisbra/Colorizer'            " show hex colors in CSS/HTML files
Plug 'glepnir/galaxyline.nvim'       " fast Lua statusline
Plug 'kyazdani42/nvim-web-devicons'  " fancy icons
Plug 'RRethy/vim-illuminate'         " highlight duplicate words
Plug 'drzel/vim-line-no-indicator'   " nice scroll indicator

Plug 'rodjek/vim-puppet'
Plug 'cappyzawa/starlark.vim'

" color schemes
Plug 'tjdevries/colorbuddy.vim'
Plug 'bkegley/gloombuddy'

Plug 'NieTiger/halcyon-neovim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'mhartington/oceanic-next'
Plug 'joshdick/onedark.vim'
Plug 'haishanh/night-owl.vim'
Plug 'bluz71/vim-nightfly-guicolors'

" Tmux
Plug 'christoomey/vim-tmux-navigator'
Plug 'melonmanchan/vim-tmux-resizer'
Plug 'benmills/vimux'

" Grep + load
Plug 'mileszs/ack.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Version control
Plug 'rhysd/git-messenger.vim'  " show commit popup with <leader>gm
Plug 'tpope/vim-fugitive'       " the git plugin
Plug 'airblade/vim-gitgutter'   " show changed line marks in gutter
Plug 'tpope/vim-rhubarb'        " enable GHE/Github links with :Gbrowse
Plug 'TimUntersberger/neogit'

" Vimscript
Plug 'tpope/vim-scriptease'

" Load private Stripe overlay packages
call SourceIfExists('~/.config/nvim/layers/private/packages.vim')

call plug#end()


" ================ Theme ========================

set termguicolors
" let g:oceanic_next_terminal_bold = 1
" let g:oceanic_next_terminal_italic = 1
colorscheme nightfly

" enable transparent terminal bg
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE
hi SignColumn guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE

" highlight hex colors in these file types
au BufNewFile,BufRead *.css,*.html,*.htm,*.sass,*.scss :ColorHighlight!

" skylark is ~python
au BufRead,BufNewFile *.sky set filetype=python

" =============== Tmux =========================

" set our shell to be bash for fast tmux switching times
" see: https://github.com/christoomey/vim-tmux-navigator/issues/72
set shell=/bin/bash\ --norc\ -i

let g:tmux_resizer_no_mappings = 0


" ============== File browser =================
"
let g:vimfiler_force_overwrite_statusline = 0
let g:vimfiler_as_default_explorer = 1
let g:vimshell_force_overwrite_statusline = 0

call vimfiler#custom#profile('default', 'context', {
  \ 'safe': 0
  \ })

" bind the minus key to show the file explorer in the dir of the current open
" buffer's file
nnoremap - :VimFilerBufferDir<CR>


" ============= ripgrep ======================

let g:ackprg = 'rg --vimgrep --no-heading'

cnoreabbrev Ack Ack!

" nnoremap <Leader>a :Ack!<Space>
" nnoremap <Leader>A :Ack!<CR>

" =============== FZF =======================

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_sink = 'e'

" floating window
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment' } }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

function! g:FzfFilesSource()
  let l:base = fnamemodify(expand('%'), ':h:.:S')
  let l:proximity_sort_path = $HOME . '/.nix-profile/bin/proximity-sort'

  let l:source_command = "rg --files --hidden --glob '!{node_modules/*,.git/*}'"

  if base == '.'
    return l:source_command
  else
    return printf('%s | %s %s', l:source_command, l:proximity_sort_path, expand('%'))
  endif
endfunction

let g:fzf_preview_cmd = g:plug_home . "/fzf.vim/bin/preview.sh {}"

noremap <C-b> :Buffers<CR>
nnoremap <silent> <Leader>f :Rg<CR>

" noremap <C-p> :call fzf#vim#files('', { 'source': g:FzfFilesSource(),
"       \ 'options': [
"       \   '--tiebreak=index', '--preview', g:fzf_preview_cmd
"       \  ]})<CR>

" ================= telescope ====================

noremap <C-p> :Telescope find_files<CR>
noremap <Leader>a :Telescope live_grep<CR>
noremap <Leader>A :Telescope grep_string<CR>

" ================= vim-test =====================

nmap <silent> <leader>T :TestNearest<CR>
nmap <silent> <leader>t :TestFile<CR>

let g:test#preserve_screen = 1
let test#neovim#term_position = "vert"
let test#vim#term_position = "vert"

let g:test#javascript#mocha#file_pattern = '\v.*_test\.(js|jsx|ts|tsx)$'

if exists('$TMUX')
  " Use tmux to kick off tests if we are in tmux currently
  let test#strategy = 'vimux'
else
  " Fallback to using terminal split
  let test#strategy = "neovim"
endif

let test#enabled_runners = ["lua#busted", "ruby#rspec"]

let test#custom_runners = {}
let test#custom_runners['ruby'] = ['rspec']
let test#custom_runners['lua'] = ['busted']


" ================= Editing plugins ==============

let splitjoin_ruby_curly_braces = 0
let splitjoin_ruby_hanging_args = 0

" vim-signature
" highlight marks dynamically based on vim-gitgutter's status
let g:SignatureMarkTextHLDynamic = 1

lua <<LUA
require("better_escape").setup({
  mapping = {"jk"},
})
LUA

" =============== version control ================

" Every time you open a git object using fugitive it creates a new buffer.
" This means that your buffer listing can quickly become swamped with
" fugitive buffers. This prevents this from becomming an issue:
autocmd BufReadPost fugitive://* set bufhidden=delete

vnoremap <leader>g :GBrowse!<CR>

nnoremap <space>gb :Gblame<CR>
nnoremap <space>gs :Gstatus<CR>
nnoremap <space>gg :Neogit<CR>

" Map git-messenger
let g:git_messenger_no_default_mappings = v:true
nmap <space>gm <Plug>(git-messenger)

" ==================== LSP ======================

set completeopt=menu,menuone,noselect

call luaeval('require("lspservers")')

" nnoremap <silent> gh :Lspsaga lsp_finder<CR>
" nnoremap <silent>K :Lspsaga hover_doc<CR>

nnoremap <silent><space>la :Lspsaga code_action<CR>
vnoremap <silent><leader>ca :<C-U>Lspsaga range_code_action<CR>

nnoremap <silent> <space>l0  <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> <space>ld  <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <space>li  :LspInfo<CR>
nnoremap <silent> <space>lh  <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <space>lD  <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <space>ln  <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <space>lr  <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> <space>lt  <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <space>lw  <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

" gutter space for lsp info on left
set signcolumn=yes

" =================== ALE =======================

" ALE config
let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_options = ''
let g:ale_javascript_eslint_use_global = 1

let g:ale_ruby_rubocop_executable = 'rubocop-daemon-wrapper'

let g:ale_ruby_rubocop_options = '--display-cop-names'
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1

" only run the linters we specify
let g:ale_linters_explicit = 1

let g:ale_linters = {
\ 'javascript': ['eslint'],
\ 'javascript.jsx': ['eslint'],
\ 'typescript': ['eslint'],
\ 'typescript.tsx': ['eslint'],
\ 'ruby': ['rubocop'],
\}

let g:ale_fixers = {
\ 'javascript': ['eslint'],
\ 'javascript.jsx': ['eslint'],
\ 'typescript': ['eslint'],
\ 'typescript.tsx': ['eslint'],
\ 'ruby': ['rubocop'],
\}

let g:ale_sign_error = '●' " Less aggressive than the default '>>'
let g:ale_sign_warning = '.'
let g:ale_disable_lsp = 1
" let g:ale_virtualtext_cursor = 1
" let g:ale_virtualtext_prefix = "      "

let g:ale_hover_to_floating_preview = 1
let g:ale_floating_preview = 1
let g:ale_hover_to_preview = 0

nnoremap <silent> gj :ALENext<cr>
nnoremap <silent> gk :ALEPrevious<cr>

" =================== Ruby =====================

function! FlipBindingPry()
  if getline('.') =~? "^\s*require 'pry'; binding\.pry\s*$"
    normal dd
  else
    normal orequire 'pry'; binding.pry
  endif

  write
endfunction

nnoremap <leader>d :call FlipBindingPry()<CR>

" ================== treesitter =================

lua <<LUA
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash',
    'css',
    'go',
    'graphql',
    'javascript',
    'json',
    'lua',
    'nix',
    'php',
    'python',
    'ruby',
    'tsx',
    'typescript',
    'yaml',
  },
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
}
LUA

" ================== status line ================
call luaeval('require("statusline")')

" ================== snippets ==================

" inoremap <silent><expr> <CR>      compe#confirm('<CR>')

let g:UltiSnipsExpandTrigger = "<nop>"
call luaeval('require("custom_snippets")')

" ================= which key ==================
call luaeval('require("which-key")')

" ================ writing mode ================

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

let g:limelight_conceal_guifg = '#777777'

" ================ lightspeed =================
lua <<LUA
require('lightspeed').setup({
  jump_to_first_match = true,
  jump_on_partial_input_safety_timeout = 400,
  highlight_unique_chars = false,
  grey_out_search_area = true,
  match_only_the_start_of_same_char_seqs = true,
  limit_ft_matches = 5,
  full_inclusive_prefix_key = '<c-x>',
})
LUA

nmap s <Plug>Lightspeed_s

" ================= Stripe ======================

" Load Stripe-specific private config
call SourceIfExists('~/.config/nvim/layers/private/config.vim')

" Load lua/init.lua
call luaeval('require("init")')
