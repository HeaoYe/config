local opt = vim.opt
opt.number = true
opt.softtabstop = 4
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.mouse:append("a")
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.whichwrap = '<,>,[,]'
vim.o.list = true
vim.o.listchars = "space:·"

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = { "*" },
    callback = function() 
        vim.highlight.on_yank({
            timeout = 600,
        })
    end,
})

vim.g.mapleader = " "
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("n", "<C-z>", "u")
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>a")
vim.keymap.set("i", "<C-z>", "<ESC>ua")
vim.keymap.set("n", "<Leader>v", "<C-w>v")
vim.keymap.set("n", "<Leader>s", "<C-w>s")
vim.keymap.set("n", "<C-Left>", "<C-w>h")
vim.keymap.set("n", "<C-Right>", "<C-w>l")
vim.keymap.set("n", "<C-Down>", "<C-w>j")
vim.keymap.set("n", "<C-Up>", "<C-w>k")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    --{
        --"RRethy/nvim-base16",
        --lazy = true,
    --},
    {
        "morhetz/gruvbox",
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = true,
    },
    {
        "nvim-treesitter/nvim-treesitter",
    },
    {
        "akinsho/bufferline.nvim",
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-tree/nvim-tree.lua",
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },
    {
        "p00f/nvim-ts-rainbow",
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = true,
    },
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        lazy = true,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
        },
        lazy = true,
    },
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
    }
})

--vim.cmd.colorscheme("base16-gruvbox-dark-soft")
vim.cmd.colorscheme("gruvbox")

require("nvim-treesitter.configs").setup({
    ensure_installed = { "make", "lua", "c", "cpp" },
    sync_install = true,
    auto_install = true,
    indent = {
        enable = true,
    },
    highlight = {
        enable = true,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    },
})

require("bufferline").setup({
    options = {
        -- diagnostics = "nvim_lsp",
        offsets = {{
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
        }},
    }
})

require("lualine").setup({
    options = {
        theme = "gruvbox",
    }
})

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({})
vim.keymap.set("n", "<Leader>t", ":NvimTreeToggle<CR>")

require("nvim-autopairs").setup({
    disable_filetype = { "TelescopePrompt" , "vim" },
})

require("mason").setup({})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").clangd.setup({
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--header-insertion=never",
        "--compile-commands-dir=build",
    },
    filetypes = { "c", "cpp" },
    capabilities = capabilities,
})

require("transparent").setup({
    --groups = { -- table: default groups
    --    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    --    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    --    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    --    'SignColumn', 'CursorLineNr', 'EndOfBuffer',
    --},
    groups = {},
    extra_groups = {}, -- table: additional groups that should be cleared
    exclude_groups = {}, -- table: groups you don't want to clear
})

-- CMPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip.loaders.from_vscode").lazy_load()

-- 下面会用到这个函数
local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(),  -- 取消补全，esc也可以退出
    ['<Ecs>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),

  -- 这里重要
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  })
})

