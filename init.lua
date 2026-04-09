-- OPTIONS --
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Don't show full line if it doesn't fit in the window
vim.opt.wrap = false
vim.opt.breakindent = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

--- [[PLUGINS]] ---

local gh = function(v)
  return 'https://github.com/' .. v
end

local plugins = {
  {
    src = gh 'mason-org/mason.nvim',
    setup = function()
      require('mason').setup()
    end,
  },
  {
    src = gh 'mason-org/mason-lspconfig.nvim',
    setup = function()
      require('mason-lspconfig').setup()
    end,
  },
  {
    src = gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
    setup = function()
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua_ls',
          'stylua',
          'rust_analyzer',
          'clangd',
          'pyright',
        },
      }
      vim.keymap.set('n', '<leader>o', '<cmd>LspClangdSwitchSourceHeader<CR>', {
        desc = 'Switch between header/source for cpp',
      })
    end,
  },
  {
    src = gh 'j-hui/fidget.nvim',
    setup = function()
      require('fidget').setup {}
    end,
  },
  {
    src = gh 'saadparwaiz1/cmp_luasnip',
    setup = function()
      require('luasnip').setup()
    end,
  },
  {
    src = gh 'L3MON4D3/LuaSnip',
    build = (function()
      -- Build Step is needed for regex support in snippets.
      -- This step is not supported in many windows environments.
      -- Remove the below condition to re-enable on windows.
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        return
      end
      return 'make install_jsregexp'
    end)(),
  },
  {
    src = gh 'hrsh7th/cmp-nvim-lsp',
    setup = function()
      require('cmp').setup {
        sources = {
          { name = 'nvim_lsp' },
        },
      }
    end,
  },
  {
    src = gh 'hrsh7th/cmp-path',
    setup = function() end,
  },
  {
    src = gh 'hrsh7th/cmp-nvim-lsp-signature-help',
    setup = function() end,
  },
  {
    src = gh 'hrsh7th/nvim-cmp',
    setup = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup()

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },
  {
    src = gh 'folke/lazydev.nvim',
    setup = function()
      require('lazydev').setup {}
    end,
  },
  {
    src = gh 'neovim/nvim-lspconfig',
    setup = function()
      local lsp_list = { 'lua_ls', 'rust_analyzer', 'clangd' }
      for _, lsp in ipairs(lsp_list) do
        vim.lsp.config(lsp, {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })
      end
      vim.lsp.enable(lsp_list)
    end,
  },
  {
    src = gh 'stevearc/conform.nvim',
    setup = function()
      require('conform').setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          rust = { 'rustfmt' },
          cpp = { 'clang-format' },
        },
      }
    end,
  },
  {
    src = gh 'mfussenegger/nvim-lint',
    setup = function()
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            require('lint').try_lint()
          end
        end,
      })
    end,
  },
  {
    src = gh 'nvim-treesitter/nvim-treesitter',
    version = 'main',
    build = ':TSUpdate',
    setup = function()
      require('nvim-treesitter').install {
        'bash',
        'diff',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        'rust',
        'cpp',
        'python',
      }

      -- God bless the issue in kickstart repo
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf)
          end
        end,
      })
    end,
  },
  {
    src = gh 'nvim-treesitter/nvim-treesitter-context',
    setup = function() end,
  },
  {
    src = gh 'rebelot/kanagawa.nvim',
    setup = function()
      require('kanagawa').setup {
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
      }
    end,
  },
  {
    src = gh 'vague-theme/vague.nvim',
  },
  {
    src = gh 'webhooked/kanso.nvim',
    setup = function()
      require('kanso').setup {
        bold = true,
        italics = false,
        compile = true,
      }
    end,
  },
  {
    src = gh 'nvim-lua/plenary.nvim',
    setup = function() end,
  },
  {
    src = gh 'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
    setup = function() end,
  },
  {
    src = gh 'nvim-telescope/telescope-file-browser.nvim',
    setup = function() end,
  },
  {
    src = gh 'nvim-telescope/telescope-live-grep-args.nvim',
    tag = '>1.0.0',
    setup = function() end,
  },
  {
    src = gh 'nvim-telescope/telescope.nvim',
    setup = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'live_grep_args')
      pcall(require('telescope').load_extension 'file_browser')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ( for repeat)' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Telescope buffers' })

      vim.keymap.set('n', '<leader>sa', function()
        require('telescope').extensions.live_grep_args.live_grep_args()
      end, { desc = '[S]earch by Grep [A]rgs' })

      vim.keymap.set('n', '<leader>fh', function()
        require('telescope').extensions.file_browser.file_browser { path = '%:p:h' }
      end, { desc = 'Open [F]ile browser [H]ere' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', '<leader>fb', function()
        require('telescope').extensions.file_browser.file_browser()
      end, { desc = '[F]ile [B]rowser' })
    end,
  },
  {
    src = gh 'windwp/nvim-autopairs',
    setup = function()
      require('nvim-autopairs').setup()
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  {
    src = gh 'nvim-mini/mini.nvim',
    setup = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
      }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    src = gh 'nvim-tree/nvim-web-devicons',
    enabled = vim.g.have_nerd_font,
  },
  { src = gh 'tpope/vim-sleuth' },
  {
    src = gh 'lewis6991/gitsigns.nvim',
    setup = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      }
    end,
  },
  {
    src = gh 'folke/which-key.nvim',
    setup = function()
      require('which-key').setup {
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        opts = {
          -- delay between pressing a key and opening which-key (milliseconds)
          -- this setting is independent of vim.opt.timeoutlen
          delay = 0,
          icons = {
            -- set icon mappings to true if you have a Nerd Font
            mappings = vim.g.have_nerd_font,
            -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
            -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
          },

          -- Document existing key chains
          spec = {
            { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
            { '<leader>t', group = '[T]oggle' },
            { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
            { 'gr', group = 'LSP Actions', mode = { 'n' } },
          },
        },
      }
    end,
  },
  {
    src = gh 'ThePrimeagen/harpoon',
    version = 'harpoon2',
    setup = function()
      local harpoon = require 'harpoon'
      harpoon:setup()
      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[A]dd harpoon mark' })
      vim.keymap.set('n', '<leader>e', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Show harpoon marks' })
      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end, { desc = 'Harpoon 1' })
      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end, { desc = 'Harpoon 2' })
      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end, { desc = 'Harpoon 3' })
      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end, { desc = 'Harpoon 4' })
    end,
  },
}

vim.pack.add(vim.tbl_map(function(plugin)
  return {
    name = plugin.name,
    src = plugin.src,
    version = plugin.version,
    tag = plugin.tag,
    build = plugin.build,
    enabled = plugin.enabled,
  }
end, plugins))

for _, plugin in ipairs(plugins) do
  _ = plugin.setup and plugin.setup()
end

vim.cmd 'colorscheme kanso'

-- Enable some additional cool things when lsp is attached
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = '[G]o to [D]efinition',
    })

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highli-- Find references for the word under your cursor.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      vim.keymap.set('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, { desc = '[T]oggle Inlay [H]ints' })
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
