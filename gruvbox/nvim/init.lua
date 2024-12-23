-- ===================
-- Basic Neovim Settings
-- ===================
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true    -- Relative line numbers
vim.opt.cursorline = true        -- Highlight the current line
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.shiftwidth = 4           -- Shift 4 spaces when tab
vim.opt.tabstop = 4              -- 1 tab == 4 spaces
vim.opt.smartindent = true       -- Automatically indent new lines
vim.opt.mouse = "a"              -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.termguicolors = true     -- Enable 24-bit colors

-- ===================
-- Key Mappings
-- ===================
vim.g.mapleader = " "  -- Set leader key to space

-- Normal mode mappings
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })   -- Save with Ctrl+S
vim.api.nvim_set_keymap('n', '<C-q>', ':q<CR>', { noremap = true, silent = true })   -- Quit with Ctrl+Q

-- Move between windows with Ctrl+Arrow
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })

-- Visual mode mappings
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })  -- Copy to system clipboard

-- ===================
-- Plugin Management (Packer)
-- ===================

-- Install packer.nvim if not already installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Auto reload Neovim when saving plugins.lua
vim.cmd [[autocmd BufWritePost init.lua source <afile> | PackerSync]]

-- Initialize packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter (Better Syntax Highlighting)
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- LSP Config
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',   -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',     -- Buffer completions
      'hrsh7th/cmp-path',       -- Path completions
      'L3MON4D3/LuaSnip',       -- Snippet engine
      'saadparwaiz1/cmp_luasnip' -- Snippet completions
    }
  }

  -- Gruvbox Theme
  use 'morhetz/gruvbox'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- ===================
-- Treesitter Setup
-- ===================
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "python", "javascript", "html", "css","json", "toml", "markdown", "bash","cpp", "c", "go" }, -- Add languages you use
  highlight = { enable = true }
}

-- ===================
-- LSP Configuration
-- ===================
local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Adds Neovim runtime to Lua LS
      },
    },
  },
}

lspconfig.pyright.setup{}    -- Python
lspconfig.ts_ls.setup{}   -- JavaScript/TypeScript
lspconfig.clangd.setup{}
lspconfig.gopls.setup {}

-- ===================
-- Autocompletion Setup (nvim-cmp)
-- ===================
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- LuaSnip expansion
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Accept completion
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- LSP source
    { name = 'luasnip' },    -- Snippet source
  }, {
    { name = 'buffer' },     -- Buffer source
  })
}

-- ===================
-- Gruvbox Theme Setup
-- ===================
vim.cmd("colorscheme gruvbox")

-- Optionally, make Normal background transparent explicitly
vim.cmd("highlight Normal guibg=none")
vim.cmd("highlight NormalFloat guibg=none")  -- For floating windows

-- ===================
-- Additional Useful Settings
-- ===================
-- Automatically resize splits when resizing Neovim window
vim.cmd [[autocmd VimResized * wincmd =]]
