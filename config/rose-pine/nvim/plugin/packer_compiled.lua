-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/hrishabhmittal/.cache/nvim/packer_hererocks/2.1.1748459687/share/lua/5.1/?.lua;/home/hrishabhmittal/.cache/nvim/packer_hererocks/2.1.1748459687/share/lua/5.1/?/init.lua;/home/hrishabhmittal/.cache/nvim/packer_hererocks/2.1.1748459687/lib/luarocks/rocks-5.1/?.lua;/home/hrishabhmittal/.cache/nvim/packer_hererocks/2.1.1748459687/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/hrishabhmittal/.cache/nvim/packer_hererocks/2.1.1748459687/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  gruvbox = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/morhetz/gruvbox"
  },
  neovim = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/neovim",
    url = "https://github.com/rose-pine/neovim"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireï\3\1\0\n\0\27\00046\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\aB\a\1\2=\a\18\0069\a\b\0009\a\19\a5\t\20\0B\a\2\2=\a\21\6B\4\2\2=\4\b\0039\4\22\0009\4\23\0044\6\3\0005\a\24\0>\a\1\0065\a\25\0>\a\2\0064\a\3\0005\b\26\0>\b\1\aB\4\3\2=\4\23\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\5\t<CR>\0\n<C-e>\0\14<C-Space>\0\n<C-f>\0\n<C-b>\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\3\fmapping\0\fsources\0\fsnippet\0\vexpand\1\0\1\vexpand\0\0\nsetup\bcmp\frequire\0" },
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n¿\4\0\0\v\0!\00056\0\0\0'\2\1\0B\0\2\0029\1\2\0009\1\3\0015\3\v\0005\4\t\0005\5\5\0005\6\4\0=\6\6\0055\6\a\0=\6\b\5=\5\n\4=\4\f\3B\1\2\0019\1\r\0009\1\3\0015\3\28\0005\4\26\0005\5\17\0005\6\15\0005\a\14\0=\a\16\6=\6\18\0055\6\23\0006\a\19\0009\a\20\a9\a\21\a'\t\22\0+\n\2\0B\a\3\2=\a\24\6=\6\25\5=\5\27\4=\4\f\3B\1\2\0019\1\29\0009\1\3\0014\3\0\0B\1\2\0019\1\30\0009\1\3\0014\3\0\0B\1\2\0019\1\31\0009\1\3\0014\3\0\0B\1\2\0019\1 \0009\1\3\0014\3\0\0B\1\2\1K\0\1\0\ngopls\vclangd\nts_ls\fpyright\1\0\1\rsettings\0\bLua\1\0\1\bLua\0\14workspace\flibrary\1\0\1\flibrary\0\5\26nvim_get_runtime_file\bapi\bvim\16diagnostics\1\0\2\16diagnostics\0\14workspace\0\fglobals\1\0\1\fglobals\0\1\2\0\0\bvim\vlua_ls\rsettings\1\0\1\rsettings\0\18rust-analyzer\1\0\1\18rust-analyzer\0\14procMacro\1\0\1\venable\2\ncargo\1\0\3\ncargo\0\14procMacro\0\16checkOnSave\2\1\0\1\16allFeatures\2\nsetup\18rust_analyzer\14lspconfig\frequire\0" },
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["themery.nvim"] = {
    loaded = true,
    path = "/home/hrishabhmittal/.local/share/nvim/site/pack/packer/start/themery.nvim",
    url = "https://github.com/zaldih/themery.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\nC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireï\3\1\0\n\0\27\00046\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\6\0005\4\4\0003\5\3\0=\5\5\4=\4\a\0039\4\b\0009\4\t\0049\4\n\0045\6\f\0009\a\b\0009\a\v\a)\tüÿB\a\2\2=\a\r\0069\a\b\0009\a\v\a)\t\4\0B\a\2\2=\a\14\0069\a\b\0009\a\15\aB\a\1\2=\a\16\0069\a\b\0009\a\17\aB\a\1\2=\a\18\0069\a\b\0009\a\19\a5\t\20\0B\a\2\2=\a\21\6B\4\2\2=\4\b\0039\4\22\0009\4\23\0044\6\3\0005\a\24\0>\a\1\0065\a\25\0>\a\2\0064\a\3\0005\b\26\0>\b\1\aB\4\3\2=\4\23\3B\1\2\1K\0\1\0\1\0\1\tname\vbuffer\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lsp\fsources\vconfig\t<CR>\1\0\1\vselect\2\fconfirm\n<C-e>\nabort\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\5\t<CR>\0\n<C-e>\0\14<C-Space>\0\n<C-f>\0\n<C-b>\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\3\fmapping\0\fsources\0\fsnippet\0\vexpand\1\0\1\vexpand\0\0\nsetup\bcmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n¿\4\0\0\v\0!\00056\0\0\0'\2\1\0B\0\2\0029\1\2\0009\1\3\0015\3\v\0005\4\t\0005\5\5\0005\6\4\0=\6\6\0055\6\a\0=\6\b\5=\5\n\4=\4\f\3B\1\2\0019\1\r\0009\1\3\0015\3\28\0005\4\26\0005\5\17\0005\6\15\0005\a\14\0=\a\16\6=\6\18\0055\6\23\0006\a\19\0009\a\20\a9\a\21\a'\t\22\0+\n\2\0B\a\3\2=\a\24\6=\6\25\5=\5\27\4=\4\f\3B\1\2\0019\1\29\0009\1\3\0014\3\0\0B\1\2\0019\1\30\0009\1\3\0014\3\0\0B\1\2\0019\1\31\0009\1\3\0014\3\0\0B\1\2\0019\1 \0009\1\3\0014\3\0\0B\1\2\1K\0\1\0\ngopls\vclangd\nts_ls\fpyright\1\0\1\rsettings\0\bLua\1\0\1\bLua\0\14workspace\flibrary\1\0\1\flibrary\0\5\26nvim_get_runtime_file\bapi\bvim\16diagnostics\1\0\2\16diagnostics\0\14workspace\0\fglobals\1\0\1\fglobals\0\1\2\0\0\bvim\vlua_ls\rsettings\1\0\1\rsettings\0\18rust-analyzer\1\0\1\18rust-analyzer\0\14procMacro\1\0\1\venable\2\ncargo\1\0\3\ncargo\0\14procMacro\0\16checkOnSave\2\1\0\1\16allFeatures\2\nsetup\18rust_analyzer\14lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
