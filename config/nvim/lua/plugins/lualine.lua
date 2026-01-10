return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Only use Matugen lualine theme if the active colorscheme is Matugen
      if vim.g.colors_name ~= "matugen" then
        opts.options.theme = "auto"
        return
      end

      local colors_path = vim.fn.stdpath("config") .. "/lua/utils/matugen.lua"
      local ok, colors = pcall(dofile, colors_path)

      -- Extra safety: ensure colors loaded correctly
      if not ok or type(colors) ~= "table" then
        opts.options.theme = "auto"
        return
      end

      local matugen_theme = {
        normal = {
          a = { fg = colors.on_primary, bg = colors.primary, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.surface_variant },
        },
        visual = {
          a = { fg = colors.on_secondary, bg = colors.secondary, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.surface_variant },
        },
        insert = {
          a = { fg = colors.on_tertiary, bg = colors.tertiary, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.surface_variant },
        },
        replace = {
          a = { fg = colors.on_error, bg = colors.error, gui = "bold" },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.surface_variant },
        },
        command = {
          a = {
            fg = colors.on_tertiary_container,
            bg = colors.tertiary_container,
            gui = "bold",
          },
          b = { fg = colors.on_surface, bg = colors.surface_variant },
          c = { fg = colors.on_surface, bg = colors.surface_variant },
        },
        inactive = {
          a = {
            fg = colors.on_surface_variant,
            bg = colors.surface_variant,
            gui = "bold",
          },
          b = { fg = colors.on_surface_variant, bg = colors.surface_variant },
          c = { fg = colors.on_surface_variant, bg = colors.surface_variant },
        },
      }

      opts.options.theme = matugen_theme
    end,
  },
}
