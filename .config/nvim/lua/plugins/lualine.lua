return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- 1. Load your Matugen colors safely
      local colors_path = vim.fn.stdpath("config") .. "/lua/utils/matugen.lua"
      local has_colors, colors = pcall(dofile, colors_path)

      -- Fallback if Matugen hasn't run yet
      if not has_colors then
        return
      end

      -- 2. Define the Custom Lualine Theme
      local matugen_theme = {
        normal = {
          -- Mode Section (A): Primary Color
          a = { fg = colors.on_primary, bg = colors.primary, gui = "bold" },
          -- File Info Section (B)
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          -- Rest of statusline (C)
          c = { fg = colors.on_surface, bg = colors.background },
        },
        visual = {
          -- Mode Section (A): Secondary Color
          a = { fg = colors.on_secondary, bg = colors.secondary, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.background },
        },
        insert = {
          -- Mode Section (A): Tertiary Color
          a = { fg = colors.on_tertiray, bg = colors.tertiary, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.background },
        },
        replace = {
          a = { fg = colors.on_error, bg = colors.error, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.background },
        },
        command = {
          a = { fg = colors.on_tertiary_container, bg = colors.tertiary_container, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.background },
        },
        inactive = {
          a = { fg = colors.on_surface_variant, bg = colors.surface_variant, gui = "bold" },
          b = { fg = colors.on_surface_variant, bg = colors.surface_variant },
          c = { fg = colors.on_surface_variant, bg = colors.background },
        },
      }

      -- 3. Apply the theme to Lualine options
      opts.options.theme = matugen_theme
    end,
  },
}
