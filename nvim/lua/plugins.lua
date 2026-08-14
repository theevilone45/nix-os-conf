local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    },
    {
    'nvim-telescope/telescope.nvim', version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        }
    },
    {
      "bfrg/vim-cpp-modern",
      ft = { "c", "cpp" }, -- optional lazy-load only for C/C++
    },
    {
        'marko-cerovac/material.nvim'
    }, 
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
          -- core sources
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "hrsh7th/cmp-cmdline",

          -- tags source
          "quangnguyen30192/cmp-nvim-tags",

          -- snippets (optional but common)
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",

          -- LSP source (optional, but recommended for C++)
          "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                  expand = function(args)
                    luasnip.lsp_expand(args.body)
                  end,
                },

                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                sources = cmp.config.sources({
                  -- tags are great for Type::member and symbol names
                    { name = "tags" },

                    { name = "path" },
                    { name = "buffer" },
                    { name = "luasnip" },
                }),
            })

            -- Cmdline completion
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })
        end,
    },
    {
        "brenton-leighton/multiple-cursors.nvim",
        version = "*",  -- Use the latest tagged version
        opts = {},  -- This causes the plugin setup function to be called
        keys = {
            {"<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"i"}, desc = "Add cursor and move down"},
        },
    },
})

