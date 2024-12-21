-----------------------
-- Plugin Installation
-----------------------
local Plug = vim.fn['plug#']

vim.call("plug#begin")

-- Themes
Plug('rose-pine/neovim', { as = 'rose-pine' })

-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = 'TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')

-- NERDTree
Plug('preservim/nerdtree')

-- FZF
Plug('ibhagwan/fzf-lua')

-- Icon Pack
Plug('nvim-tree/nvim-web-devicons')

-- LSP progress messages.
Plug('j-hui/fidget.nvim')

-- Infer tab width based on file.
Plug('tpope/vim-sleuth')

-- Surround
Plug('tpope/vim-surround')

-- Autocompletion.
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')

-- Open Line in GitHub
Plug('ruanyl/vim-gh-line')

-- Diff Viewer
Plug('sindrets/diffview.nvim')

-- Gitsigns
Plug('lewis6991/gitsigns.nvim')

-- Tab Manipulation
Plug('gcmt/taboo.vim')
Plug('vim-scripts/Tabmerge')

-- Buffer Manipulation
Plug('Asheq/close-buffers.vim')

-- Mouse Hover
Plug('lewis6991/hover.nvim')

vim.call("plug#end")

---------
-- Misc
---------
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set expandtab")
vim.cmd("set nowrap")
vim.opt.number = true

vim.g.mapleader = ","

vim.cmd("command! ConfigEdit :e /Users/matt/.config/nvim/init.lua")
vim.cmd("command! ConfigReload :luafile /Users/matt/.config/nvim/init.lua")
vim.cmd("command! Work :e /Users/matt/Documents/WORK.md")
vim.cmd("command! QuickfixClear :call setqflist([])")

require("hover").setup {
    init = function()
        -- Require providers
        require("hover.providers.lsp")
        -- require('hover.providers.gh')
        -- require('hover.providers.gh_user')
        -- require('hover.providers.jira')
        -- require('hover.providers.dap')
        -- require('hover.providers.fold_preview')
        require('hover.providers.diagnostic')
        -- require('hover.providers.man')
        -- require('hover.providers.dictionary')
    end,
    preview_opts = {
        border = 'single'
    },
    -- Whether the contents of a currently open hover window should be moved
    -- to a :h preview-window when pressing the hover keymap.
    preview_window = false,
    title = true,
    mouse_providers = {
        'LSP'
    },
    mouse_delay = 1000
}

vim.keymap.set("n", "<leader>k", require("hover").hover, {desc = "hover.nvim"})
vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
vim.keymap.set("n", "<C-n>", function() require("hover").hover_switch("next") end, {desc = "hover.nvim (next source)"})
vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
-- vim.o.mousemoveevent = true

-------------
-- Treesitter
-------------
require'nvim-treesitter.configs'.setup {
  textobjects = {
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[a"] = "@parameter.inner",
      },
    },
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
      selection_modes = {
        ['@function.outer'] = 'V',
      },
    },
  },
}

-----------------
-- Autocompletion
-----------------
local cmp = require'cmp'

cmp.setup({
mapping = cmp.mapping.preset.insert({
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<Tab>'] = cmp.mapping.confirm({ select = true }),
}),
sources = cmp.config.sources({
  { name = 'nvim_lsp' },
}, {
  { name = 'buffer' },
})
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
mapping = cmp.mapping.preset.cmdline(),
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
}),
matching = { disallow_symbol_nonprefix_matching = false }
})

-------
-- LSP
-------
local lspconfig = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Set up different language servers.
lspconfig.rust_analyzer.setup{
  -- cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
  capabilities = capabilities,
  -- init_options = {
  --   lspMux = {
  --     version = "1",
  --     method = "connect",
  --     server = "rust-analyzer"
  --   }
  -- },
  settings = {
    ['rust-analyzer'] = {
      rustfmt = {
        extraArgs = { '+nightly' }
      },
      checkOnSave = {
        extraArgs = { '--target-dir', '/tmp/rust-analyzer-check' }
      }
    }
  }
}
lspconfig.tsserver.setup{}
lspconfig.pyright.setup{}
lspconfig.java_language_server.setup{
  cmd = { "/Users/matt/Code/SelfCompiled/java-language-server/dist/lang_server_mac.sh" },

  -- Workaround for https://github.com/georgewfraser/java-language-server/issues/267
  handlers = {
    ['client/registerCapability'] = function(err, result, ctx, config)
      local registration = {
        registrations = { result },
      }
      return vim.lsp.handlers['client/registerCapability'](err, registration, ctx, config)
    end
  },
}

-- vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {})
-- vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, {})

-- Turn on progress messages.
require'fidget'.setup{}

-----------------
-- Format on Save
-----------------
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.rs" },
  callback = function(args)
    vim.lsp.buf.format({ async = false })
  end
})

------------
-- FZF
------------
local fzf = require('fzf-lua')
fzf.setup({
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept"
    }
  }
})
vim.keymap.set('n', 'ff', fzf.files, {})
vim.keymap.set('n', 'fg', fzf.live_grep, {})
vim.keymap.set('n', 'fb', fzf.buffers, {})
vim.keymap.set('n', 'fw', fzf.lsp_live_workspace_symbols, {})
vim.keymap.set('n', 'fs', fzf.lsp_document_symbols, {})
vim.keymap.set('n', 'fd', fzf.lsp_workspace_diagnostics, {})
vim.keymap.set('n', 'gr', fzf.lsp_references, {})
vim.keymap.set('n', 'gi', function() fzf.lsp_implementations({ jump_to_single_result = true }) end, {})
vim.keymap.set('n', 'gd', function() fzf.lsp_definitions({ jump_to_single_result = true }) end, {})
vim.keymap.set('n', 'gy', function() fzf.lsp_typedefs({ jump_to_single_result = true }) end, {})
vim.keymap.set('n', '<leader>a', fzf.lsp_code_actions, {})

---------
-- Theme
---------

vim.opt.laststatus = 3 -- Or 3 for global statusline
vim.opt.statusline = " %f %m %= %l:%c ♥ "

vim.api.nvim_set_hl(0, '@lsp.typemod.method.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.function.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.struct.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.enum.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.interface.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.parameter.declaration', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.selfKeyword.declaration', { bold = true })

require('rose-pine').setup({
  styles = {
    bold = true,
    italic = false,
    transparency = true,
  },
  highlight_groups = {
    Keyword = { bold = true },
    StatusLine = { fg = "iris", bg = "iris", blend = 10 },
    StatusLineNC = { fg = "subtle", bg = "surface" },
    SpecialComment = { fg = "subtle" },
  },
})

vim.cmd("set background=dark")
vim.cmd("set termguicolors")
vim.cmd("colorscheme rose-pine-moon")
vim.cmd("set cursorline")

-- vim.g.lightline = { colorscheme = "rosepine_moon" }

--------------
-- Diff Viewer
--------------
require('diffview').setup {
  keymaps = {
    file_panel = {
      {"n", "<leader>cF", function()
        local file_path = require'diffview.lib'.get_current_view().panel.cur_file.path
        local left_commit = require'diffview.lib'.get_current_view().left.commit
        local right_commit = require'diffview.lib'.get_current_view().right.commit
        local cmd = "GIT_EXTERNAL_DIFF='difftastic --display side-by-side-show-both' git diff " .. left_commit .. ":" .. file_path .. " " ..
          right_commit .. ":" ..  file_path

        local popup_buf = vim.api.nvim_create_buf(false, true)
        local width = vim.o.columns-6
        local height = vim.o.lines-6
        local win_opts = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          relative = "editor",
          width = width,
          height = height,
          anchor = "NW",
          row = 3,
          col = 3,
          noautocmd = true,
        }
        local popup_win = vim.api.nvim_open_win(popup_buf, true, win_opts)

        vim.fn.termopen(cmd)
      end, {desc= "Diff with difftastic"}}
    },
  },
}

-----------------------
-- Run after everything
-----------------------

-- Stop nvim from auto wrapping my damn text, I have a formatter!
vim.cmd("set textwidth=0")

-- Show tab numbers in Taboo.
vim.cmd("let g:taboo_tab_format=' %N %f%m '")
vim.cmd("let g:taboo_renamed_tab_format=' %N %l%m '")

-- Stop nvim from continuing comments onto the next line.
vim.opt.formatoptions:remove { 'c', 'r', 'o' }

require('gitsigns').setup()

