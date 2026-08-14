local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<C-Left>", "<C-w>h")
map("n", "<C-Down>", "<C-w>j")

map("n", "<C-Up>", "<C-w>k")
map("n", "<C-Right>", "<C-w>l")


map("t", "<Esc>", [[<C-\><C-n>]])
map("t", "<C-Left>", [[<C-\><C-n><C-w>h]])
map("t", "<C-Down>", [[<C-\><C-n><C-w>j]])
map("t", "<C-Up>", [[<C-\><C-n><C-w>k]])
map("t", "<C-Right>", [[<C-\><C-n><C-w>l]])

function _G.ToggleTerminal()
  vim.cmd("botright split | resize 16 | terminal")
end

map("n", "<leader>t", ToggleTerminal)

map("n", "<leader>e", "<Cmd>Neotree toggle<CR>")

map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

map("n", "<leader>q", "<Cmd>qa!<CR>")
map("n", "<leader>wq", "<Cmd>xa<CR>")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- NORMAL mode
vim.keymap.set("n", "<A-Up>",   ":m .-2<CR>==", { silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { silent = true })

-- VISUAL mode (move selected lines)
vim.keymap.set("v", "<A-Up>",   ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true })
