local glo = vim.g
glo.mapleader = " "
glo.maplocalleader = "\\"

local opt = vim.o
opt.cursorline = true
opt.encoding = "utf-8"
opt.expandtab = true
opt.list = true
opt.listchars = "tab:»·,trail:·,nbsp:·"
opt.mouse = "nvi"
opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.showmode = false
opt.softtabstop = 4
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.updatetime = 50
opt.whichwrap = "b,s,<,>,h,l"
opt.wrap = true
opt.cmdheight = 0
opt.showcmdloc = "statusline"

local remap = vim.keymap.set
remap({ "n", "x" }, ";", ":")
remap("n", "n", "nzzzv")
remap("n", "N", "Nzzzv")
remap("n", "<C-d>", "<C-d>zz")
remap("n", "<C-u>", "<C-u>zz")
remap("x", "p", "pgvy")
remap("i", ",", ",<C-g>u")
remap("i", ".", ".<C-g>u")
remap({ "n", "x" }, "<Leader>y", '"+y')
remap({ "n", "x" }, "<Leader>Y", '"+y$')
remap("t", "<C-Esc>", "<C-\\><C-n>")

remap("n", "i", function() return #vim.fn.getline(".") == 0 and [["_cc]] or "i" end, { expr = true })
remap("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true, noremap = true })
remap("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true, noremap = true })

vim.api.nvim_create_user_command("W", "write !sudo tee %", {})

local mini_path = vim.fn.stdpath("data") .. "/site" .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch", "stable", "https://github.com/echasnovski/mini.nvim", mini_path })
    vim.cmd("packadd mini.nvim | helptags ALL")
end

require("mini.deps").setup()
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

now(function() require('mini.sessions').setup() end)
now(function() require('mini.statusline').setup() end)
now(function() require('mini.tabline').setup() end)

now(function()
    require("mini.base16").setup({
        palette = { base00 = "#1e1e2e", base01 = "#181825", base02 = "#313244", base03 = "#45475a", base04 = "#585b70", base05 = "#cdd6f4", base06 = "#f5e0dc", base07 = "#b4befe", base08 = "#f38ba8", base09 = "#fab387", base0A = "#f9e2af", base0B = "#a6e3a1", base0C = "#94e2d5", base0D = "#89b4fa", base0E = "#cba6f7", base0F = "#f2cdcd"},
    })
end)

now(function() require("mini.basics").setup({ mappings = { windows = true } }) end)

now(function()
    require('mini.icons').setup({
        use_file_extension = function(ext, _)
            local suf3, suf4 = ext:sub(-3), ext:sub(-4)
            return suf3 ~= 'scm' and suf3 ~= 'txt' and suf3 ~= 'yml' and suf4 ~= 'json' and suf4 ~= 'yaml'
        end,
    })
    MiniIcons.mock_nvim_web_devicons()
    later(MiniIcons.tweak_lsp_kind)
end)

later(function() require("mini.align").setup() end)
later(function() require("mini.bracketed").setup() end)
later(function() require("mini.bracketed").setup() end)
later(function() require("mini.cursorword").setup() end)
later(function() require("mini.diff").setup() end)
later(function() require('mini.extra').setup() end)
later(function() require('mini.git').setup() end)
later(function() require('mini.hipatterns').setup() end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.trailspace').setup() end)

later(function()
    local ai = require("mini.ai")
    local ts = ai.gen_spec.treesitter
    local fc = ai.gen_spec.function_call
    local pr = ai.gen_spec.pair
    ai.setup({
        n_lines = 500,
        custom_textobjects = {
            a = ts({ a = { "@attribute.outer", "@parameter.outer" }, i = { "@attribute.inner", "@parameter.inner" } }),
            c = ts({ a = "@class.outer", i = "@class.inner" }),
            f = ts({ a = "@function.outer", i = "@function.inner" }),
            o = ts({ a = { "@block.outer", "@conditional.outer", "@loop.outer" }, i = { "@block.inner", "@conditional.inner", "@loop.inner" } }),
            t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
            d = { "%f[%d]%d+" },
            e = {
                { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
                "^().*()$",
            },
            u = fc(),
            U = fc({ name_pattern = "[%w_]" }),
            ["*"] = pr("*", "*", { type = "greedy" }),
            ["_"] = pr("_", "_", { type = "greedy" }),
        },
    })
end)

later(function()
    require("mini.completion").setup({
        window = {
            info = { border = "double" },
            signature = { border = "double" },
        },
    })
end)

later(function()
    require('mini.files').setup()
    remap("n", "<C-o>", function() MiniFiles.open() end)
end)

later(function() require('mini.jump').setup({ mappings = { repeat_jump = "" }, delay = { highlight = 10000000 }}) end)
later(function() require('mini.surround').setup({ search_method = 'cover_or_next' }) end)
later(function() require('mini.pairs').setup({ modes = { insert = true, command = true, terminal = true } }) end)
later(function() require("mini.move").setup({ mappings = { left = "H", down = "J", up = "K", right = "L" } }) end)

now_if_args(function()
    add({
        source = "supermaven-inc/supermaven-nvim",
        hooks = { post_checkout = function() require("supermaven-nvim.api").start() end },
    })

    require("supermaven-nvim").setup({
        log_level = "off",
        keymaps = { accept_suggestion = "<M-CR>", clear_suggestion = "<M-]>", accept_word = "<M-w>" },
    })
end)

later(function()
    add({
        source = "ggandor/leap.nvim",
        depends = { "tpope/vim-repeat" },
    })

    require("leap").setup({ equivalence_classes = { " \t\r\n" } })
    require("leap.user").set_repeat_keys("<enter>", "<s-enter>")
    remap({ "n", "x" }, "<CR>", function()
        require("leap").leap({ target_windows = require("leap.user").get_focusable_windows() })
    end)
end)

now_if_args(function()
    add({
        source = 'nvim-treesitter/nvim-treesitter',
        checkout = 'master',
        hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
    })
    add('nvim-treesitter/nvim-treesitter-textobjects')

    require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        incremental_selection = { enable = false },
        textobjects = { enable = false },
        indent = { enable = true },
    })
end)

later(function()
    add({ source = "mg979/vim-visual-multi" })
end)

now(function()
    add({ source = "folke/snacks.nvim" })

    require("snacks").setup({
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        git = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        notify = { enabled = true },
        picker = { enabled = true },
        quickfile = { enabled = true },
        terminal = { enabled = true },
    })

    remap({ "n", "x" }, "<Leader>bq", function() Snacks.bufdelete() end)
    remap({ "n", "x" }, "<Leader>bQ", function() Snacks.bufdelete.other() end)
    remap({ "n", "x" }, "<Leader>gb", function() Snacks.git.blame_line() end)

    remap({ "n", "x" }, "<C-p>", function() Snacks.picker.files() end)
    remap({ "n", "x" }, "<C-g>", function() Snacks.picker.grep() end)

    remap({ "n", "x" }, "<Leader>t", function() Snacks.terminal.toggle() end)
end)
