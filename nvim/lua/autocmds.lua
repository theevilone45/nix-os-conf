local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local general = augroup("GeneralSettings", { clear = true })

autocmd("VimEnter", {
  group = general,
  callback = function(data)
    local is_directory = vim.fn.isdirectory(data.file) == 1
    local no_name = data.file == ""

    if is_directory then
      vim.cmd.cd(data.file)
      vim.cmd("Neotree show")
    elseif no_name then
      vim.cmd("Neotree show")
    end
  end,
})

autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})

autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
