{
  lib,
  pkgs,
  ...
}: {
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

    # reduce time before hover diagnostics appear
    updatetime = 300;
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
      {name = "copilot";}
      {name = "nvim_lsp";}
      {name = "path";}
      {name = "buffer";}
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
        "_" = ["trim_whitespace"];
        go = ["goimports" "golines" "gofmt" "gofumpt"];
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
        json = ["jq"];
        lua = ["stylua"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        rust = ["rustfmt"];
        sh = ["shellcheck" "shellharden" "shfmt"];
        terraform = ["terraform_fmt"];
      };
      formatters = {
        alejandra = {
          command = "${lib.getExe pkgs.alejandra}";
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
  };
  plugins.gitlinker = {
    enable = true;
    actionCallback = "open_in_browser";
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
      ansiblels.enable = true;
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
  plugins.neogit = {
    enable = true;
  };
  plugins.neo-tree = {
    enable = true;
    filesystem.followCurrentFile.enabled = true;
    filesystem.useLibuvFileWatcher = true;
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
  plugins.telescope = {
    enable = true;
    extensions.fzf-native.enable = true;
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
    select = {
      enable = true;
      lookahead = true;
      keymaps = {
        "aa" = "@parameter.outer";
        "ia" = "@parameter.inner";
        "af" = "@function.outer";
        "if" = "@function.inner";
        "ac" = "@class.outer";
        "ic" = "@class.inner";
        "ii" = "@conditional.inner";
        "ai" = "@conditional.outer";
        "il" = "@loop.inner";
        "al" = "@loop.outer";
        "at" = "@comment.outer";
      };
    };
    move = {
      enable = true;
      gotoNextStart = {
        "]m" = "@function.outer";
        "]]" = "@class.outer";
      };
      gotoNextEnd = {
        "]M" = "@function.outer";
        "][" = "@class.outer";
      };
      gotoPreviousStart = {
        "[m" = "@function.outer";
        "[[" = "@class.outer";
      };
      gotoPreviousEnd = {
        "[M" = "@function.outer";
        "[]" = "@class.outer";
      };
    };
  };
  plugins.treesitter-refactor = {
    enable = true;
    highlightDefinitions.enable = true;
  };
  plugins.trouble.enable = true;
  plugins.tmux-navigator.enable = true;
  plugins.web-devicons.enable = true;
  plugins.which-key.enable = true;

  extraPackages = with pkgs; [
    tmux
  ];

  extraPlugins = [
    pkgs.vimPlugins.vimux
    pkgs.vimPlugins.guess-indent-nvim
    pkgs.vimPlugins.vim-test
  ];

  extraConfigLua = ''
    require("guess-indent").setup({})

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
    # Telescope
    {
      key = "<leader>o";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Find files";
    }
    {
      key = "<leader>g";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Find files";
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

    # Oil
    {
      key = "-";
      action = "<cmd>Oil<CR>";
      options.desc = "Open parent directory";
    }

    # treesitter-context
    {
      key = "[c";
      action = "<cmd>lua require(\"treesitter-context\").go_to_context(vim.v.count1)<CR>";
      options.desc = "Jump to beginning of context";
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
      event = ["BufReadPost"];
      pattern = "quickfix";
      command = "nnoremap <buffer> <CR> <CR>";
    }
  ];
}
