-- C++
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"cpp", "c"},
    callback = function()
	vim.opt_local.tabstop = 4
	vim.opt_local.shiftwidth = 4
	vim.opt_local.expandtab = true
	vim.opt_local.smartindent = true
    end
})
