local plugin = require('plugin')
require('plugin/configs/luasnip')
require('plugin/configs/nvim_tree')
require('plugin/configs/lsp')

-- Common
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autochdir = true
vim.o.number = true

-- Look and feel
vim.cmd("colorscheme one-nvim")
vim.cmd("set background=light")
vim.o.guifont = "FiraCode NF:h12"

-- Lua Snip
vim.cmd([[
    " Expand snippets in insert mode with Tab
    imap <silent><expr> <Tab> luasnip#expandable() ? '<Plug>luasnip-expand-snippet' : '<Tab>'

    " Jump forward in through tabstops in insert and visual mode with Control-f
    imap <silent><expr> <C-f> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<C-f>'
    smap <silent><expr> <C-f> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<C-f>' 

    " Cycle forward through choice nodes with Control-f (for example)
    imap <silent><expr> <C-j> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-j>'
    smap <silent><expr> <C-j> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-j>' 

    " Jump backward through snippet tabstops with Shift-Tab
    imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>' 
]])

require("luasnip.loaders.from_lua").load({
    paths = vim.fn.expand("~/AppData/Local/nvim/snip/")
})

-- Screen line movement
vim.cmd([[
    function! ScreenMovement(movement)
       if &wrap
          return "g" . a:movement
       else
          return a:movement
       endif
    endfunction
    onoremap <silent> <expr> j ScreenMovement("j")
    onoremap <silent> <expr> k ScreenMovement("k")
    onoremap <silent> <expr> 0 ScreenMovement("0")
    onoremap <silent> <expr> ^ ScreenMovement("^")
    onoremap <silent> <expr> $ ScreenMovement("$")
    nnoremap <silent> <expr> j ScreenMovement("j")
    nnoremap <silent> <expr> k ScreenMovement("k")
    nnoremap <silent> <expr> 0 ScreenMovement("0")
    nnoremap <silent> <expr> ^ ScreenMovement("^")
    nnoremap <silent> <expr> $ ScreenMovement("$")
]])

-- Toggle wrap
function toggle_wrap()
    if vim.o.wrap then
        vim.o.wrap = false
    else
        vim.o.wrap = true
        vim.o.columns = 86
        vim.o.linebreak = true
        vim.o.breakindent = true
    end
end

vim.api.nvim_set_keymap("n", "<C-S-W>", ":lua toggle_wrap()<CR>", { silent = true })


-- Nvim Tree
vim.g.nvim_tree_side = "left"
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_ignore = {".git", "node_modules", ".cache"}

vim.api.nvim_set_keymap("n", "<C-S-E>", ":NvimTreeToggle<CR>", {
    silent = true
})

