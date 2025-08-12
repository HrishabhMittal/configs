
-- ===================
-- Basic Neovim Settings
-- ===================

vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight the current line

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Shift 4 spaces when tab
vim.opt.tabstop = 4 -- 1 tab == 4 spaces

vim.opt.smartindent = true -- Automatically indent new lines

vim.opt.mouse = "a" -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

vim.opt.termguicolors = true -- Enable 24-bit colors

-- ===================
-- Key Mappings
-- ===================

vim.g.mapleader = " " -- Set leader key to space

-- Normal mode mappings
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true }) -- Save with Ctrl+S
vim.api.nvim_set_keymap('n', '<C-q>', ':q<CR>', { noremap = true, silent = true }) -- Quit with Ctrl+Q

-- Move between windows with Ctrl+Arrow keys
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })

-- Visual mode mappings
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true }) -- Copy to system clipboard

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

-- Auto reload Neovim when saving init.lua
vim.cmd [[autocmd BufWritePost init.lua source | PackerSync]]

-- Initialize packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter (Better Syntax Highlighting)
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- VHDL Syntax Highlighting
  use 'vhda/vhdl'                             -- VHDL syntax and indentation

  -- LSP Config
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',   -- Buffer completions
      'hrsh7th/cmp-path',     -- Path completions
      'L3MON4D3/LuaSnip',     -- Snippet engine
      'saadparwaiz1/cmp_luasnip' -- Snippet completions
    }
  }

  -- Themes
  use 'zaldih/themery.nvim'
  use 'morhetz/gruvbox'
  use 'rose-pine/neovim'
  use 'neanias/everforest-nvim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- ===================
-- Treesitter Setup
-- ===================
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "lua", "python", "javascript", "html", "css", "json",
    "toml", "markdown", "bash", "cpp", "c", "go", "rust",
    "vhdl"  -- Add VHDL Tree-sitter parser if available
  },
  highlight = { enable = true }
}

-- ===================
-- LSP Configuration
-- ===================
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Common on_attach for LSP servers
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  -- Add more LSP keymaps if needed
end

-- Enhance capabilities for nvim-cmp
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Lua LSP
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Python LSP
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- C/C++ LSP
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Go LSP
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Rust LSP (rust-analyzer) with diagnostics and Clippy on save
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = true,
      diagnostics = { enable = true },
    },
  },
}


lspconfig.vhdl_ls.setup({
  on_attach = on_attach,       -- your existing on_attach function
  capabilities = capabilities, -- your existing capabilities table
})
-- ===================
-- Autocompletion Setup (nvim-cmp)
-- ===================
local cmp = require'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
}

-- ===================
-- Theme manager setup
-- ===================
require("themery").setup({
  themes = { "gruvbox", "rose-pine", "everforest" },
  livePreview = true,
})

-- Optional transparency
-- vim.cmd("highlight Normal guibg=none")
-- vim.cmd("highlight NormalFloat guibg=none")

-- ===================
-- Additional Useful Settings
-- ===================

-- Automatically resize splits when resizing Neovim window
vim.cmd [[autocmd VimResized * wincmd =]]

-- Configure diagnostic display
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})
