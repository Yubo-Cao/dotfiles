vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Package manager
    use 'wbthomason/packer.nvim'

    -- Vim in browser
    use {
        'glacambre/firenvim',
        run = function()
            vim.fn['firenvim#install'](0)
        end
    }

    -- LaTeX support
    use 'lervag/vimtex'

    -- Atom theme
    use 'Th3Whit3Wolf/one-nvim'

    -- lua snip
    use {
        "L3MON4D3/LuaSnip",
        requires = {
            "rafamadriz/friendly-snippets", -- for some prefined snippets
        },
        version = "<CurrentMajor>.*",
        build = "make install_jsregexp"
    }
    
    -- Nvim tree
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- for file icons
        },
        tag = 'nightly' 
    }     

    -- Copilot
    use "github/copilot.vim"

    -- LSP
    use 'neovim/nvim-lspconfig' -- Configurations for LSP
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
end)
