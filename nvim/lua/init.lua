local neogit = require('neogit')
neogit.setup {}

------------ telescope --------------

local telescope = require('telescope')

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--vimgrep",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "❯ ",
    selection_caret = "❯ ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    file_ignore_patterns = {"%.jpg", "%.png", "%.gif", "%.svg", "%.mp4"},
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
  },
  pickers = {
    file_browser = {
      path_display = { "shorten" },
    },
    find_files = {
      find_command = { "rg", "--files", "--hidden", "--glob", "!{node_modules/*,.git/*}" },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    } ,
  },
})

telescope.load_extension('fzf')
