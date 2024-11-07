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

remap("n", "<C-h>", "<C-w>h")
remap("n", "<C-j>", "<C-w>j")
remap("n", "<C-k>", "<C-w>k")
remap("n", "<C-l>", "<C-w>l")

remap("n", "i", function()
    if #vim.fn.getline(".") == 0 then
        return [["_cc]]
    else
        return "i"
    end
end, { expr = true })

remap({ "n", "x" }, ",y", '"+y', { desc = "Yank To Clipboard" })
remap({ "n", "x" }, ",Y", '"+y$', { desc = "Yank Line To Clipboard" })

local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        '--branch', 'stable',
    'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
end

plugins = {
    "mini.ai", "mini.align", "mini.basics", "mini.bracketed",
    "mini.clue", "mini.colors", "mini.completion", "mini.cursorword",
    "mini.deps", "mini.diff", "mini.doc", "mini.extra", "mini.files",
    "mini.git", "mini.hipatterns", "mini.indentscope", "mini.jump2d",
    "mini.map", "mini.misc", "mini.move", "mini.notify", "mini.pairs",
    "mini.pick", "mini.sessions", "mini.splitjoin", "mini.statusline",
    "mini.surround", "mini.tabline", "mini.trailspace", "mini.visits",
}

for _, plugin in ipairs(plugins) do
    require(plugin).setup()
end

require("mini.base16").setup({
    palette = {
        base00 = "#1e1e2e",
        base01 = "#181825",
        base02 = "#313244",
        base03 = "#45475a",
        base04 = "#585b70",
        base05 = "#cdd6f4",
        base06 = "#f5e0dc",
        base07 = "#b4befe",
        base08 = "#f38ba8",
        base09 = "#fab387",
        base0A = "#f9e2af",
        base0B = "#a6e3a1",
        base0C = "#94e2d5",
        base0D = "#89b4fa",
        base0E = "#cba6f7",
        base0F = "#f2cdcd",
    },
})

local add = MiniDeps.add

add({
    source = "nvim-telescope/telescope.nvim",
    checkout = "0.1.8",
    depends = { "nvim-lua/plenary.nvim" },
})

add({
    source = "supermaven-inc/supermaven-nvim",
    hooks = { post_checkout = function()
        local api = require("supermaven-nvim.api")
        api.start()
        api.use_free_version()
    end },
})

require("mini.jump").setup({ mappings = { repeat_jump = "" } })

remap("n", "<C-o>", function() MiniFiles.open() end)

remap("n", "<C-p>", "<Cmd>Telescope find_files<CR>")

require("supermaven-nvim").setup({ log_level = "off" })
