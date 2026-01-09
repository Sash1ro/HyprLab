vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    local cs_file = vim.fn.stdpath("config") .. "/lua/config/colorscheme.txt"

    local file = io.open(cs_file, "r")
    if file then
      local colorscheme = file:read("*l")
      file:close()

      local ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme)
      vim.cmd("TransparentEnable")
      if not ok then
        vim.notify("Could not load colorscheme: " .. colorscheme .. "\n" .. err, vim.log.levels.WARN)
      end
    else
      vim.notify("Colorscheme file not found: " .. cs_file, vim.log.levels.WARN)
    end
    local ok, lualine = pcall(require, "lualine")
    if ok then
      lualine.setup()
      lualine.refresh()
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local cs_file = vim.fn.stdpath("config") .. "/lua/config/colorscheme.txt"

    local file = io.open(cs_file, "r")
    if file then
      local colorscheme = file:read("*l")
      file:close()

      local ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme)
      vim.cmd("TransparentEnable")
      if not ok then
        vim.notify("Could not load colorscheme: " .. colorscheme .. "\n" .. err, vim.log.levels.WARN)
      end
    else
      vim.notify("Colorscheme file not found: " .. cs_file, vim.log.levels.WARN)
    end
    local ok, lualine = pcall(require, "lualine")
    if ok then
      lualine.setup()
      lualine.refresh()
    end
  end,
})
