require('plugin')

-- Common
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autochdir = true
vim.o.number = true

-- Look and feel
vim.cmd("colorscheme one-nvim")
vim.cmd("set background=light")
vim.o.guifont = "FiraCode NF:h8"

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
