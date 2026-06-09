{
  lib,
  pkgs,
  ...
}:
{
  # Space as leader
  globals.mapleader = " ";

  vimAlias = true;

  opts = {
    # show line numbers
    number = true;

    # default tabs to 2 spaces
    tabstop = 2;
    shiftwidth = 2;

    # case insensitive search unless i use a capital letter
    ignorecase = true;
    smartcase = true;

    # start searching while i type
    incsearch = true;

    # begin scrolling before cursor hits the very bottom of the buffer
    scrolloff = 5;

    # single-line mouse wheel steps for smoother scrolling (default ver:3)
    mousescroll = "ver:1,hor:1";

    # reduce time before hover diagnostics appear
    updatetime = 300;

    # automatically read files when changed outside of neovim
    # useful when Claude Code modifies files in a separate tmux pane
    autoread = true;

    # always write by truncating the original file rather than the
    # rename-then-write-new strategy; prevents tmp files from briefly
    # appearing on disk and confusing file watchers (e.g. Astro's glob-loader)
    backupcopy = "yes";
  };

  clipboard = {
    # Always yank to system clipboard
    # This should pass through tmux + OSC52 when SSHed into dev machine
    register = "unnamedplus";
  };

  colorschemes.catppuccin.enable = true;
  plugins.cmp = {
    enable = true;
    settings.sources = [
      { name = "copilot"; }
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
    ];
    settings.mapping = {
      __raw = ''
        cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        })
      '';
    };
  };
  plugins.aerial = {
    enable = true;
    # make symbols outline per-window, not per-buffer
    settings.attach_mode = "global";
  };
  plugins.conform-nvim = {
    enable = true;

    settings = {
      formatters_by_ft = {
        "_" = [ "trim_whitespace" ];
        go = [
          "goimports"
          "golines"
          "gofmt"
          "gofumpt"
        ];
        javascript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        typescriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        javascriptreact = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          stop_after_first = true;
        };
        json = [ "jq" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        python = [
          "isort"
          "black"
        ];
        rust = [ "rustfmt" ];
        sh = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        terraform = [ "terraform_fmt" ];
      };
      formatters = {
        nixfmt = {
          command = "${lib.getExe pkgs.nixfmt-rfc-style}";
        };
        black = {
          command = "${lib.getExe pkgs.black}";
        };
        goimports = {
          command = "${lib.getExe' pkgs.gotools "goimports"}";
        };
        isort = {
          command = "${lib.getExe pkgs.isort}";
        };
        jq = {
          command = "${lib.getExe pkgs.jq}";
        };
        prettierd = {
          command = "${lib.getExe pkgs.prettierd}";
        };
        stylua = {
          command = "${lib.getExe pkgs.stylua}";
        };
        shellcheck = {
          command = "${lib.getExe pkgs.shellcheck}";
        };
        shfmt = {
          command = "${lib.getExe pkgs.shfmt}";
        };
        shellharden = {
          command = "${lib.getExe pkgs.shellharden}";
        };
      };
      format_on_save = ''
        function(bufnr)
          -- Only allow auto-format for languages with standard formatters
          local allowed_filetypes = {
            "go",        -- gofmt is the standard
            "rust",      -- rustfmt is the standard
            "nix",       -- alejandra/nixfmt are standard
            "terraform", -- terraform fmt is the standard
            "python",    -- black/isort are widely accepted standards
            "lua",       -- stylua is widely accepted for neovim configs
          }

          if not vim.tbl_contains(allowed_filetypes, vim.bo[bufnr].filetype) then
            return
          end

          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          -- Disable autoformat for files in a certain path
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("/node_modules/") then
            return
          end
          return { timeout_ms = 1000, lsp_fallback = true }
        end
      '';
    };
  };
  plugins.copilot-lua = {
    enable = true;
    settings = {
      # Disable in favor of copilot-cmp
      suggestion.enabled = false;
      panel.enabled = false;
    };
  };
  plugins.copilot-cmp = {
    enable = true;
  };
  plugins.gitsigns = {
    enable = true;
    settings = {
      on_attach = ''
        function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({']c', bang = true})
            else
              gitsigns.nav_hunk('next')
            end
          end, {desc = 'Next git change'})

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({'[c', bang = true})
            else
              gitsigns.nav_hunk('prev')
            end
          end, {desc = 'Previous git change'})

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk, {desc = 'Stage hunk'})
          map('n', '<leader>hr', gitsigns.reset_hunk, {desc = 'Reset hunk'})
          map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = 'Stage hunk'})
          map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc = 'Reset hunk'})
          map('n', '<leader>hS', gitsigns.stage_buffer, {desc = 'Stage buffer'})
          map('n', '<leader>hu', gitsigns.undo_stage_hunk, {desc = 'Undo stage hunk'})
          map('n', '<leader>hR', gitsigns.reset_buffer, {desc = 'Reset buffer'})
          map('n', '<leader>hp', gitsigns.preview_hunk, {desc = 'Preview hunk'})
          map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, {desc = 'Blame line'})
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {desc = 'Toggle blame'})
          map('n', '<leader>hd', gitsigns.diffthis, {desc = 'Diff this'})
          map('n', '<leader>hD', function() gitsigns.diffthis('~') end, {desc = 'Diff this ~'})
          map('n', '<leader>td', gitsigns.toggle_deleted, {desc = 'Toggle deleted'})

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = 'Select git hunk'})
        end
      '';
    };
  };
  plugins.gitportal = {
    enable = true;
    settings = {
      always_include_current_line = true;
      always_use_commit_hash_in_url = true;
      default_remote = "origin";
    };
  };
  plugins.indent-blankline = {
    enable = true;
    settings.scope.enabled = true;
  };
  plugins.lualine.enable = true;
  plugins.lsp = {
    enable = true;
    servers = {
      nixd.enable = true;
      ruby_lsp = {
        enable = true;
      };
      gopls.enable = true;
      terraformls.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      ts_ls.enable = true;
      bashls = {
        enable = true;
        # Only use for diagnostics, not formatting
        onAttach.function = ''
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        '';
      };
    };
    keymaps = {
      extra = [
        {
          key = "<leader>l";
          action = "";
          options.desc = "+lsp";
        }
        {
          mode = "n";
          key = "<leader>li";
          action = "<cmd>LspInfo<cr>";
          options.desc = "Show LSP info";
        }
        {
          mode = "n";
          key = "<leader>ll";
          action.__raw = "function() vim.lsp.codelens.refresh() end";
          options.desc = "LSP CodeLens refresh";
        }
        {
          mode = "n";
          key = "<leader>lL";
          action.__raw = "function() vim.lsp.codelens.run() end";
          options.desc = "LSP CodeLens run";
        }
        {
          mode = "n";
          key = "<leader>ld";
          action.__raw = "function() vim.diagnostic.open_float() end";
          options.desc = "Show diagnostics in floating window";
        }
        {
          mode = "n";
          key = "<leader>ls";
          action.__raw = "function() Snacks.picker.lsp_symbols({ tree = true }) end";
          options.desc = "LSP symbols tree";
        }
      ];

      lspBuf = {
        "<leader>la" = {
          action = "code_action";
          desc = "LSP code action";
        };

        gd = {
          action = "definition";
          desc = "Go to definition";
        };

        gI = {
          action = "implementation";
          desc = "Go to implementation";
        };

        gy = {
          action = "type_definition";
          desc = "Go to type definition";
        };

        grr = {
          action = "references";
          desc = "Go to references";
        };

        grn = {
          action = "rename";
          desc = "Rename symbol";
        };

        K = {
          action = "hover";
          desc = "LSP hover";
        };

        "<leader>i" = {
          action = "hover";
          desc = "LSP hover";
        };
      };
    };
  };
  plugins.diffview = {
    enable = true;
  };
  plugins.neogit = {
    enable = true;
  };
  plugins.neo-tree = {
    enable = true;
    settings = {
      filesystem = {
        follow_current_file.enabled = true;
        use_libuv_file_watcher = true;
      };
      log_level = "error";
    };
  };
  plugins.none-ls = {
    enable = true;
    sources.diagnostics.codespell.enable = true;
  };
  plugins.oil = {
    enable = true;
  };
  plugins.precognition = {
    enable = true;
    settings = {
      startVisible = false;
    };
  };
  plugins.rainbow-delimiters.enable = true;
  plugins.render-markdown.enable = true;
  # On-demand distraction-free prose, toggled with <leader>z. Floats the
  # current buffer at a fixed reading width with a dimmed backdrop. Unlike
  # true-zen/NoNeckPain it doesn't create real side split windows, so there
  # are no empty panes to accidentally navigate into.
  plugins.zen-mode = {
    enable = true;
    settings = {
      window = {
        width = 100;
        options = {
          # Pin signcolumn so render-markdown heading signs don't reflow
          # text on insert↔normal transitions; drop line numbers for focus.
          signcolumn = "yes";
          number = false;
          relativenumber = false;
        };
      };
    };
  };
  plugins.snacks = {
    enable = true;
    settings.picker.enable = true;
    settings.image = {
      enabled = true;
      # Render PDFs at 2x retina-ish density. Skip -trim so the typeset
      # page margins are preserved as natural page padding, then add a
      # solid-color border in the editor bg for breathing room around
      # the page itself.
      convert.magick.pdf = [
        "-density"
        384
        "{src}[{page}]"
        "-background"
        "white"
        "-alpha"
        "remove"
        "-bordercolor"
        "#1E1E2E"
        "-border"
        "200x200"
      ];
    };
  };
  plugins.treesitter = {
    enable = true;
    settings.indent.enable = true;
  };
  plugins.treesitter-context = {
    enable = true;
  };
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          aa = "@parameter.outer";
          ia = "@parameter.inner";
          af = "@function.outer";
          "if" = "@function.inner";
          ac = "@class.outer";
          ic = "@class.inner";
          ii = "@conditional.inner";
          ai = "@conditional.outer";
          il = "@loop.inner";
          al = "@loop.outer";
          at = "@comment.outer";
        };
      };
      move = {
        enable = true;
        goto_next_start = {
          "]m" = "@function.outer";
          "]]" = "@class.outer";
        };
        goto_next_end = {
          "]M" = "@function.outer";
          "][" = "@class.outer";
        };
        goto_previous_start = {
          "[m" = "@function.outer";
          "[[" = "@class.outer";
        };
        goto_previous_end = {
          "[M" = "@function.outer";
          "[]" = "@class.outer";
        };
      };
    };
  };
  plugins.treesitter-refactor = {
    enable = true;
    settings.highlight_definitions.enable = true;
  };
  plugins.trouble.enable = true;
  plugins.tmux-navigator.enable = true;
  plugins.web-devicons.enable = true;
  plugins.which-key.enable = true;

  extraPackages = with pkgs; [
    tmux
    imagemagick
    ghostscript
  ];

  extraPlugins = [
    pkgs.vimPlugins.vimux
    pkgs.vimPlugins.guess-indent-nvim
    pkgs.vimPlugins.vim-test
  ];

  extraConfigLua = ''
    require("guess-indent").setup({})

    -- snacks.image.util.fit converts PDF pixel dims into a "logical" size by
    -- dividing by the rendered DPI and multiplying by 96. The result is small
    -- enough to skip the scale-down branch, leaving PDFs rendered at a fixed
    -- tiny size regardless of pane size. Strip opts.info so fit always uses
    -- raw pixel dimensions and overflows the pane → scales to fit.
    do
      local util = require("snacks.image.util")
      local orig_fit = util.fit
      function util.fit(file, cells, opts)
        opts = vim.deepcopy(opts or {})
        opts.info = nil
        return orig_fit(file, cells, opts)
      end
    end

    -- snacks caches converted PDFs by sha256(src + page) with no mtime check,
    -- so a recompiled PDF reuses the stale PNG. Wipe matching cache entries
    -- when the file changes on disk, before the reload triggers re-render.
    vim.api.nvim_create_autocmd("FileChangedShell", {
      pattern = "*.pdf",
      callback = function()
        local cache_dir = vim.fn.stdpath("cache") .. "/snacks/image"
        local src = vim.fn.expand("<afile>:p")
        local base = vim.fn.fnamemodify(src, ":t:r"):gsub("[^%w%.]+", "-")
        for _, file in ipairs(vim.fn.glob(cache_dir .. "/*-" .. base .. ".*", false, true)) do
          vim.fn.delete(file)
        end
      end,
    })

    -- Treat .mdx files as markdown for syntax highlighting
    vim.filetype.add({
      extension = {
        mdx = "markdown",
      },
    })

    -- Prose-friendly soft-wrap for typst (and markdown). Word-boundary wrap
    -- with continuation indent makes semantic hard-wrapped paragraphs read
    -- like flowing prose instead of getting truncated mid-word.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "typst", "markdown" },
      callback = function()
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.showbreak = "↪ "

        -- Pin the signcolumn so render-markdown's heading signs popping
        -- in/out between insert and normal mode doesn't reflow text.
        vim.opt_local.signcolumn = "yes"

        -- Move by visual lines through soft wraps; counted jumps (5j) still
        -- move by real lines so relativenumber targeting keeps working.
        local opts = { buffer = true, expr = true, silent = true }
        vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", opts)
        vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", opts)
        vim.keymap.set({ "n", "x" }, "$", "v:count == 0 ? 'g$' : '$'", opts)
        vim.keymap.set({ "n", "x" }, "|", "v:count == 0 ? 'g0' : '|'", opts)
      end,
    })

    -- Centered, distraction-free prose is on-demand via zen-mode (<leader>z),
    -- not auto-forced on every markdown/typst buffer. zen-mode floats the
    -- buffer with a dimmed backdrop instead of inserting real empty split
    -- windows, so there are no focusable "noop" panes to navigate around.
    -- See plugins.zen-mode below for the config.

    -- Configure diagnostics
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })

    -- Show diagnostics in a floating window on hover
    vim.api.nvim_create_autocmd("CursorHold", {
      pattern = "*",
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = 'rounded',
          source = 'always',
          prefix = ' ',
          scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
      end,
    })

    -- recto agent-link bridge. recto launches this neovim with `--listen` and,
    -- when a companion session runs `recto focus <file>:<lines>`, drives the
    -- editor here via `--remote-expr "v:lua.RectoFocus(...)"`. We jump the
    -- cursor to the span and paint the range with a sticky extmark highlight,
    -- mirroring recto's own focus highlight so the agent can point your eyes at
    -- exactly the lines it's talking about. recto falls back to a plain
    -- edit+center if these helpers aren't loaded, so this is purely the nice path.
    do
      local ns = vim.api.nvim_create_namespace("recto_focus")

      local function clear_all()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) then
            vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
          end
        end
      end

      -- Highlight group for the focused span; links to Visual by default so it
      -- tracks the colorscheme, but a theme can define RectoFocus to override.
      vim.api.nvim_set_hl(0, "RectoFocus", { link = "Visual", default = true })

      _G.RectoFocus = function(path, start_line, end_line)
        -- Don't reload the current buffer (would clobber unsaved edits); only
        -- :edit when we're actually switching files.
        local target = vim.fn.fnamemodify(path, ":p")
        local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
        if target ~= current then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end

        clear_all()

        -- No line range (vim.NIL over the wire) means whole-file focus: we've
        -- opened the file, nothing to highlight.
        if start_line == nil or start_line == vim.NIL then
          return ""
        end
        if end_line == nil or end_line == vim.NIL then
          end_line = start_line
        end

        local last = vim.api.nvim_buf_line_count(0)
        start_line = math.max(1, math.min(start_line, last))
        end_line = math.max(start_line, math.min(end_line, last))

        vim.api.nvim_win_set_cursor(0, { start_line, 0 })
        vim.cmd("normal! zz")

        for l = start_line, end_line do
          vim.api.nvim_buf_set_extmark(0, ns, l - 1, 0, {
            line_hl_group = "RectoFocus",
            hl_eol = true,
          })
        end
        return ""
      end

      _G.RectoClear = function()
        clear_all()
        return ""
      end
    end
  '';

  extraConfigVim = ''
    " use vimux in vim-test
    let test#strategy = "vimux"
    let test#preserve_screen = 1
    let test#go#gotest#options = '-v'
  '';

  keymaps = [
    # Aerial
    {
      key = "<leader>a";
      action = "<cmd>AerialToggle<CR>";
      options.desc = "Toggle aerial symbols outline";
    }

    # Distraction-free / centered prose
    {
      key = "<leader>z";
      action = "<cmd>ZenMode<CR>";
      options.desc = "Toggle Zen mode";
    }

    # LazyVim-style quick access
    {
      key = "<leader><space>";
      action.__raw = ''
        function() Snacks.picker.files({ hidden = true, ignored = true }) end
      '';
      options.desc = "Find all files (including gitignored)";
    }
    {
      key = "<leader>/";
      action.__raw = ''
        function() Snacks.picker.grep() end
      '';
      options.desc = "Grep";
    }

    # Backup keybindings
    {
      key = "<leader>o";
      action.__raw = ''
        function() Snacks.picker.files() end
      '';
      options.desc = "Find files (alias)";
    }

    # Snacks picker
    {
      key = "<leader>f";
      action = "";
      options.desc = "+find";
    }
    {
      key = "<leader>ff";
      action.__raw = ''
        function() Snacks.picker.files() end
      '';
      options.desc = "Find files (respecting gitignore)";
    }
    {
      key = "<leader>fF";
      action.__raw = ''
        function() Snacks.picker.files({ hidden = true, ignored = true }) end
      '';
      options.desc = "Find all files (including gitignored)";
    }
    {
      key = "<leader>fg";
      action.__raw = ''
        function() Snacks.picker.grep() end
      '';
      options.desc = "Find words (live grep)";
    }
    {
      key = "<leader>fb";
      action.__raw = ''
        function() Snacks.picker.buffers() end
      '';
      options.desc = "Find buffers";
    }
    {
      key = "<leader>fo";
      action.__raw = ''
        function() Snacks.picker.recent() end
      '';
      options.desc = "Find recent files";
    }
    {
      key = "<leader>f<CR>";
      action.__raw = ''
        function() Snacks.picker.resume() end
      '';
      options.desc = "Resume last search";
    }
    {
      key = "<leader>fs";
      action.__raw = ''
        function() Snacks.picker.lsp_symbols() end
      '';
      options.desc = "Find LSP symbols";
    }

    # Vimux
    {
      key = "<leader>v";
      action = "<cmd>VimuxPromptCommand<CR>";
      options.desc = "Run command in Vimux";
    }
    {
      key = "<CR>";
      action = ":wa <CR> :VimuxRunLastCommand<CR>";
      options.desc = "Rerun last command in Vimux";
    }

    # Quickfix fuzzy picker
    {
      key = "<leader>q";
      action.__raw = ''
        function() Snacks.picker.qflist() end
      '';
      options.desc = "Fuzzy pick quickfix list";
    }

    # Oil
    {
      key = "-";
      action = "<cmd>Oil<CR>";
      options.desc = "Open parent directory";
    }

    # treesitter-context
    {
      key = "[C";
      action = "<cmd>lua require(\"treesitter-context\").go_to_context(vim.v.count1)<CR>";
      options.desc = "Jump to beginning of context";
    }

    # gitportal
    {
      key = "<leader>g";
      action = "";
      options.desc = "+git";
    }
    {
      key = "<leader>gg";
      action.__raw = ''
        function() Snacks.picker.grep() end
      '';
      options.desc = "Live grep (escape hatch)";
    }
    {
      key = "<leader>gy";
      action.__raw = ''
        function() require("gitportal").copy_link_to_clipboard() end
      '';
      options.desc = "Copy git link to clipboard";
    }
    {
      key = "<leader>gy";
      mode = "v";
      action.__raw = ''
        function() require("gitportal").copy_link_to_clipboard() end
      '';
      options.desc = "Copy git link for selection";
    }
    {
      key = "<leader>go";
      action.__raw = ''
        function() require("gitportal").open_file_in_browser() end
      '';
      options.desc = "Open git link in browser";
    }
    {
      key = "<leader>go";
      mode = "v";
      action.__raw = ''
        function() require("gitportal").open_file_in_browser() end
      '';
      options.desc = "Open git link for selection in browser";
    }

    # diffview
    {
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      options.desc = "Open diffview (unstaged changes)";
    }
    {
      key = "<leader>gD";
      action = "<cmd>DiffviewClose<CR>";
      options.desc = "Close diffview";
    }
    {
      key = "<leader>gc";
      action = "<cmd>ClaudeChanges<CR>";
      options.desc = "Changed hunks to quickfix (vs index)";
    }
    {
      key = "<leader>gC";
      action = "<cmd>ClaudeChanges origin/main<CR>";
      options.desc = "Changed hunks to quickfix (vs origin/main)";
    }

    # conform-nvim
    {
      key = "<leader>F";
      action = "<cmd>lua require(\"conform\").format({ bufnr = args.buf, async = true })<CR>";
      options.desc = "Format buffer";
    }

    # precognition
    {
      key = "<leader>P";
      action = "<cmd>lua require('precognition').peek()<CR>";
      options.desc = "Peek precognition hints";
    }

    # neotest
    {
      key = "<leader>t";
      action = "";
      options.desc = "+test";
    }
    {
      key = "<leader>tt";
      action.__raw = ''
        function() require("neotest").run.run(vim.fn.expand("%")) end
      '';
      options.desc = "Run File";
    }
    {
      key = "<leader>tT";
      action.__raw = ''
        function() require("neotest").run.run(vim.uv.cwd()) end
      '';
      options.desc = "Run All Test Files";
    }
    {
      key = "<leader>tr";
      action.__raw = ''
        function() require("neotest").run.run() end
      '';
      options.desc = "Run Nearest";
    }
    {
      key = "<leader>tl";
      action.__raw = ''
        function() require("neotest").run.run_last() end
      '';
      options.desc = "Run Last";
    }
    {
      key = "<leader>ts";
      action.__raw = ''
        function() require("neotest").summary.toggle() end
      '';
      options.desc = "Toggle Summary";
    }
    {
      key = "<leader>to";
      action.__raw = ''
        function() require("neotest").output.open({ enter = true; auto_close = true;}) end
      '';
      options.desc = "Show Output";
    }
    {
      key = "<leader>tO";
      action.__raw = ''
        function() require("neotest").output_panel.toggle() end
      '';
      options.desc = "Toggle Output Panel";
    }
    {
      key = "<leader>tS";
      action.__raw = ''
        function() require("neotest").run.stop() end
      '';
      options.desc = "Stop";
    }
    {
      key = "<leader>tw";
      action.__raw = ''
        function() require("neotest").watch.toggle(vim.fn.expand("%")) end
      '';
      options.desc = "Toggle Watch";
    }

    # neo-tree
    {
      key = "<leader>nt";
      action = "<cmd>Neotree toggle<CR>";
      options.desc = "Toggle neo-tree";
    }

    # vim-test
    {
      key = "<leader>tn";
      action = "<cmd>TestNearest<CR>";
      options.desc = "Run nearest test in vim-test";
    }
    {
      key = "<leader>tf";
      action = "<cmd>TestFile<CR>";
      options.desc = "Run file tests in vim-test";
    }
  ];

  autoCmd = [
    {
      event = [ "BufReadPost" ];
      pattern = "quickfix";
      command = "nnoremap <buffer> <CR> <CR>";
    }

    # Automatic file reloading when files change outside of neovim
    # This is useful when Claude Code modifies files in a separate tmux pane
    # NOTE: For tmux users, add `set -g focus-events on` to ~/.tmux.conf
    {
      event = [
        "FocusGained"
        "BufEnter"
        "CursorHold"
        "CursorHoldI"
      ];
      pattern = "*";
      callback.__raw = ''
        function()
          -- Only check for changes if not in command-line mode
          if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == "" then
            vim.cmd('checktime')
          end
        end
      '';
    }

    # Show a warning when a file is reloaded
    {
      event = [ "FileChangedShellPost" ];
      pattern = "*";
      callback.__raw = ''
        function()
          vim.api.nvim_echo({
            {"File changed on disk. Buffer reloaded.", "WarningMsg"}
          }, false, {})
        end
      '';
    }
  ];
}
