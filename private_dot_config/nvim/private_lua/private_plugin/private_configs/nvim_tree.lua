-- disable internal file maanger
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0

-- enable highlight groups
vim.opt.termguicolors = true

-- setup with options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
        { key = "n", action = "dir_down" }
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- keybinds
vim.g.nvim_tree_side = "left"
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_ignore = {".git", "node_modules", ".cache"}

vim.api.nvim_set_keymap("n", "<C-S-E>", ":NvimTreeToggle<CR>", {
    silent = true
})

