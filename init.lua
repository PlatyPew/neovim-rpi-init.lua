local mini_path = vim.fn.stdpath("data") .. "/site" .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch", "stable", "https://github.com/echasnovski/mini.nvim", mini_path })
    vim.cmd("packadd mini.nvim | helptags ALL")
end

require("mini.deps").setup()
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = vim.fn.argc(-1) > 0 and now or later

local palette = { base00 = "#1e1e2e", base01 = "#181825", base02 = "#313244", base03 = "#45475a", base04 = "#585b70", base05 = "#cdd6f4", base06 = "#f5e0dc", base07 = "#b4befe", base08 = "#f38ba8", base09 = "#fab387", base0A = "#f9e2af", base0B = "#a6e3a1", base0C = "#94e2d5", base0D = "#89b4fa", base0E = "#cba6f7", base0F = "#f2cdcd"}

local opt = vim.o
local glo = vim.g
local remap = vim.keymap.set

now(function()
    glo.mapleader = " "
    glo.maplocalleader = "\\"

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
end)

later(function()
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
end)

now(function() require('mini.sessions').setup() end)
now(function() require('mini.statusline').setup() end)
now(function() require('mini.tabline').setup() end)

now(function()
    require("mini.base16").setup({
        palette = palette,
    })
end)

now(function() require("mini.basics").setup({ mappings = { windows = true } }) end)

now(function()
    require('mini.files').setup()
    remap("n", "<C-o>", function() MiniFiles.open() end)
end)

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
later(function() require('mini.extra').setup() end)
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
    require("mini.diff").setup({
        mappings = {
            goto_first = '[G',
            goto_prev = '[g',
            goto_next = ']g',
            goto_last = ']G',
        },
        view = {
            style = "sign",
            signs = { add = "█", change = "▒", delete = "" },
        },
    })
end)

later(function()
    require('mini.git').setup()

    local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
    remap("n", "<Leader>gS", "<Cmd>Git add -- %<CR>")
    remap("n", "<Leader>gR", "<Cmd>Git reset -- %<CR>")
    remap("n", "<Leader>gc", "<Cmd>Git commit<CR>")
    remap("n", "<Leader>gC", "<Cmd>Git commit --amend<CR>")
    remap("n", "<Leader>gd", "<Cmd>Git diff<CR>")
    remap("n", "<Leader>gD", "<Cmd>Git diff -- %<CR>")
    remap("n", "<Leader>gl", "<Cmd>" .. git_log_cmd .. "<CR>")
    remap("n", "<Leader>gL", "<Cmd>" .. git_log_cmd .. " --follow -- %<CR>")
    remap("n", "<Leader>go", function() MiniDiff.toggle_overlay() end)
end)

later(function() require('mini.surround').setup({ search_method = 'cover_or_next' }) end)
later(function() require('mini.pairs').setup({ modes = { insert = true, command = true, terminal = true } }) end)
later(function() require("mini.move").setup({ mappings = { left = "H", down = "J", up = "K", right = "L" } }) end)

later(function()
    add({ source = "folke/flash.nvim" })

    local hl = vim.api.nvim_set_hl
    hl(0, "FlashBackdrop", { fg = palette.base04 })
    hl(0, "FlashLabel", { fg = palette.base08, bg = palette.base00, bold = true })
    hl(0, "FlashMatch", { fg = palette.base07, bg = palette.base00 })
    hl(0, "FlashCurrent", { fg = palette.base09, bg = palette.base00 })
    hl(0, "FlashPrompt", { link = "NormalFloat" })

    remap({ "n", "x" }, "<CR>", function() require("flash").jump() end)
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
    add({ source = "jake-stewart/multicursor.nvim" })

    local mc = require("multicursor-nvim")
    mc.setup()

    remap({"n", "v"}, "<A-up>", function() mc.lineAddCursor(-1) end)
    remap({"n", "v"}, "<A-down>", function() mc.lineAddCursor(1) end)
    remap({"n", "v"}, "<A-S-up>", function() mc.lineSkipCursor(-1) end)
    remap({"n", "v"}, "<A-S-down>", function() mc.lineSkipCursor(1) end)
    remap({"n", "v"}, "<A-left>", mc.prevCursor)
    remap({"n", "v"}, "<A-right>", mc.nextCursor)

    remap({"n", "v"}, "<C-n>", function() mc.matchAddCursor(1) end)
    remap({"n", "v"}, "<C-q>", function() mc.matchSkipCursor(1) end)

    remap({"n", "v"}, "<leader>x", mc.deleteCursor)
    remap("n", "<c-leftmouse>", mc.handleMouse)

    remap("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        elseif mc.hasCursors() then
            mc.clearCursors()
        else
        end
    end)

    remap("v", "M", mc.matchCursors)
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
        picker = { enabled = true },
        quickfile = { enabled = true },
        terminal = { enabled = true },

        dashboard = {
            enabled = true,
            preset = {
                header = [[
  ____             _    _               
 / ___| _   _  ___| | _| | ___  ___ ___ 
 \___ \| | | |/ __| |/ / |/ _ \/ __/ __|
  ___) | |_| | (__|   <| |  __/\__ \__ \
 |____/ \__,_|\___|_|\_\_|\___||___/___/]],
            },
            sections = {
                { section = "header" },
                { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            }
        },
    })

    remap({ "n", "x" }, "<Leader>bq", function() Snacks.bufdelete() end)
    remap({ "n", "x" }, "<Leader>bQ", function() Snacks.bufdelete.other() end)
    remap({ "n", "x" }, "<Leader>gb", function() Snacks.git.blame_line() end)

    remap({ "n", "x" }, "<C-p>", function() Snacks.picker.smart() end)
    remap({ "n", "x" }, "<C-g>", function() Snacks.picker.grep() end)
    remap({ "n", "x" }, "<Leader>u", function() Snacks.picker.undo() end)

    remap({ "n", "x" }, "<Leader>t", function() Snacks.terminal.toggle() end)
end)
