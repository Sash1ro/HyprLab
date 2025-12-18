-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local opt = vim.opt
vim.g.lazyvim_prettier_needs_config = false
opt.scrolloff = 0
opt.number = true
opt.relativenumber = false

opt.whichwrap = "b,s,<,>"
