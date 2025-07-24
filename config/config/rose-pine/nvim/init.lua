
-- ===================
-- Basic Neovim Settings
-- ===================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- ===================
-- Key Mappings
-- ===================
vim.g.mapleader = " "

vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })

-- ===================
-- Plugin Management (Packer)
-- ===================
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

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  callback = function()
    vim.cmd("source %")
    vim.cmd("PackerSync")
  end,
})

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- LSP Config
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')

      -- Rust
      lspconfig.rust_analyzer.setup {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            procMacro = { enable = true },
          },
        },
      }

      -- Lua
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        },
      }

      -- Python
      lspconfig.pyright.setup{}

      -- JavaScript/TypeScript
      lspconfig.ts_ls.setup{}

      -- C/C++
      lspconfig.clangd.setup{}

      -- Go
      lspconfig.gopls.setup{}
    end
  }

  -- Autocompletion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
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
    end
  }

  -- Themes
  use 'zaldih/themery.nvim'
  use 'morhetz/gruvbox'
  use 'rose-pine/neovim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- ===================
-- Treesitter Setup
-- ===================
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "lua", "python", "javascript", "html", "css", "json", "toml", "markdown",
    "bash", "cpp", "c", "go", "rust"
  },
  highlight = { enable = true }
}

-- ===================
-- Format Rust on Save
-- ===================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- ===================
-- Theme Switcher
-- ===================
require("themery").setup({
  themes = {"gruvbox", "rose-pine"},
  livePreview = true,
})

-- Resize splits when terminal resizes
vim.cmd [[autocmd VimResized * wincmd =]]
