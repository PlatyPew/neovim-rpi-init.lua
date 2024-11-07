vim.o.cursorline = true
vim.o.encoding = "utf-8"
vim.o.expandtab = true
vim.o.list = true
vim.o.listchars = "tab:»·,trail:·,nbsp:·"
vim.o.mouse = "nvi"
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.showmode = false
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 4
vim.o.updatetime = 50
vim.o.whichwrap = "b,s,<,>,h,l"
vim.o.wrap = true
vim.o.cmdheight = 0
vim.o.showcmdloc = "statusline"

vim.keymap.set({ "n", "x" }, ";", ":")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "p", "pgvy")
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set({ "n", "x" }, ",y", '"+y', { desc = "Yank To Clipboard" })
vim.keymap.set({ "n", "x" }, ",Y", '"+y$', { desc = "Yank Line To Clipboard" })

vim.keymap.set("n", "i", function()
    if #vim.fn.getline(".") == 0 then
        return [["_cc]]
    else
        return "i"
    end
end, { expr = true })

vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, noremap = true })

vim.api.nvim_create_user_command("W", "write !sudo tee %", {})

local mini_path = vim.fn.stdpath('data') .. '/site' .. '/pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch', 'stable', 'https://github.com/echasnovski/mini.nvim', mini_path })
    vim.cmd('packadd mini.nvim | helptags ALL')
end

plugins = {
    "mini.ai", "mini.align", "mini.basics", "mini.bracketed", "mini.clue", "mini.colors", "mini.completion", "mini.cursorword", "mini.deps", "mini.diff", "mini.doc", "mini.extra", "mini.files", "mini.git", "mini.hipatterns", "mini.indentscope", "mini.map", "mini.misc", "mini.notify", "mini.pairs", "mini.pick", "mini.sessions", "mini.splitjoin", "mini.statusline", "mini.surround", "mini.tabline", "mini.trailspace", "mini.visits"
}

for _, plugin in ipairs(plugins) do
    require(plugin).setup()
end

require("mini.base16").setup({
    palette = {base00 = "#1e1e2e", base01 = "#181825", base02 = "#313244", base03 = "#45475a", base04 = "#585b70", base05 = "#cdd6f4", base06 = "#f5e0dc", base07 = "#b4befe", base08 = "#f38ba8", base09 = "#fab387", base0A = "#f9e2af", base0B = "#a6e3a1", base0C = "#94e2d5", base0D = "#89b4fa", base0E = "#cba6f7", base0F = "#f2cdcd",},
})

require("mini.move").setup({ mappings = { left = "H", down = "J", up = "K", right = "L" } })

vim.keymap.set("n", "<C-o>", function() MiniFiles.open() end)

MiniDeps.add({
    source = "nvim-telescope/telescope.nvim",
    checkout = "0.1.8",
    depends = { "nvim-lua/plenary.nvim" },
})

vim.keymap.set("n", "<C-p>", "<Cmd>Telescope find_files<CR>")

MiniDeps.add({
    source = "supermaven-inc/supermaven-nvim",
    hooks = { post_checkout = function() require("supermaven-nvim.api").start() end },
})

require("supermaven-nvim").setup({ log_level = "off", keymaps = { accept_suggestion = "<M-CR>", clear_suggestion = "<M-]>", accept_word = "<M-w>" } })

MiniDeps.add({
    source = "ggandor/leap.nvim",
    depends = { "tpope/vim-repeat" },
})

require("leap").setup({ equivalence_classes = { " \t\r\n" } })
require("leap.user").set_repeat_keys("<enter>", "<s-enter>")

vim.keymap.set( "n", "<CR>", function() require("leap").leap({ target_windows = require("leap.user").get_focusable_windows() }) end )
