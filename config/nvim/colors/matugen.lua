local colors_path = vim.fn.stdpath("config") .. "/lua/utils/matugen.lua"
local has_colors, colors = pcall(dofile, colors_path)

if not has_colors then
  vim.notify("Matugen colors not found. Run matugen first!", vim.log.levels.ERROR)
  return
end

-- Clear existing highlights
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "matugen"

local groups = {
  -- Base
  Normal = { fg = colors.foreground, bg = colors.background },
  NormalFloat = { fg = colors.foreground, bg = colors.surface_variant },
  FloatBorder = { fg = colors.outline, bg = colors.surface_variant },

  -- UI Elements
  Cursor = { fg = colors.background, bg = colors.primary },
  CursorLine = { bg = colors.surface_variant },
  CursorLineNr = { fg = colors.primary, bold = true },
  LineNr = { fg = colors.outline },
  VertSplit = { fg = colors.outline },
  StatusLine = { fg = colors.on_primary_container, bg = colors.primary_container },

  -- Syntax Highlighting (Material You Mapping)
  Comment = { fg = colors.outline, italic = true },
  Constant = { fg = colors.tertiary },
  String = { fg = colors.secondary },
  Identifier = { fg = colors.on_surface },
  Function = { fg = colors.primary, bold = true },
  Statement = { fg = colors.tertiary },
  Keyword = { fg = colors.tertiary, italic = true },
  Type = { fg = colors.secondary },
  Special = { fg = colors.primary },

  -- Visual Selection
  Visual = { bg = colors.secondary_container, fg = colors.on_secondary_container },

  -- Search
  Search = { bg = colors.primary, fg = colors.on_primary },
  IncSearch = { bg = colors.tertiary, fg = colors.on_tertiary },

  -- Diagnostics
  DiagnosticError = { fg = colors.error },
  DiagnosticWarn = { fg = colors.tertiary },
  DiagnosticInfo = { fg = colors.secondary },
  DiagnosticHint = { fg = colors.outline },

  -- Git (Gitsigns/LazyGit)
  Added = { fg = colors.secondary },
  Modified = { fg = colors.tertiary },
  Removed = { fg = colors.error },
}

-- Apply Highlights
for group, params in pairs(groups) do
  vim.api.nvim_set_hl(0, group, params)
end
