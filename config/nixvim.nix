{
  lib,
  pkgs,
  ...
}: {
  # Space as leader
  globals.mapleader = " ";

  globalOpts = {
    number = true;
    ts = 2;
    shiftwidth = 2;
    ignorecase = true;
    smartcase = true;
    incsearch = true;
    scrolloff = 5;
  };

  colorschemes.catppuccin.enable = true;
  plugins.cmp = {
    enable = true;
    settings.sources = [
      {name = "nvim_lsp";}
      {name = "path";}
      {name = "buffer";}
    ];
    settings.mapping = {
      "<C-Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      "<C-n>" = "cmp.mapping.select_next_item()";
      "<C-p>" = "cmp.mapping.select_prev_item()";
      "<C-e>" = "cmp.mapping.abort()";
      "<C-b>" = "cmp.mapping.scroll_docs(-4)";
      "<C-f>" = "cmp.mapping.scroll_docs(4)";
      "<CR>" = "cmp.mapping.confirm({ select = true })";
      "<C-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
    };
  };
  plugins.conform-nvim = {
    enable = true;

    settings = {
      formatters_by_ft = {
        "_" = ["trim_whitespace"];
        "*" = ["codespell"];
        go = ["goimports" "golines" "gofmt" "gofumpt"];
        javascript = [["prettierd" "prettier"]];
        json = ["jq"];
        lua = ["stylua"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        rust = ["rustfmt"];
        sh = ["shellcheck" "shellharden" "shfmt"];
        terraform = ["terraform_fmt"];
      };
      formatters = {
        black = {
          command = "${lib.getExe pkgs.black}";
        };
        isort = {
          command = "${lib.getExe pkgs.isort}";
        };
        alejandra = {
          command = "${lib.getExe pkgs.alejandra}";
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
          local ignore_filetypes = { }
          if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
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
  plugins.gitsigns = {
    enable = true;
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
    };
    keymaps = {
      extra = [
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

        K = {
          action = "hover";
          desc = "LSP hover";
        };
      };
    };
  };
  plugins.none-ls.enable = true;
  plugins.nvim-osc52 = {
    enable = true;
  };
  plugins.oil = {
    enable = true;
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
    swap = {
      enable = true;
      swapNext = {
        "<leader>a" = "@parameters.inner";
      };
      swapPrevious = {
        "<leader>A" = "@parameter.outer";
      };
    };
  };
  plugins.treesitter-refactor = {
    enable = true;
    highlightDefinitions.enable = true;
  };
  plugins.trouble.enable = true;
  plugins.tmux-navigator.enable = true;
  plugins.which-key.enable = true;

  extraPlugins = [
    pkgs.vimPlugins.vimux
    pkgs.vimPlugins.guess-indent-nvim
  ];

  extraConfigLua = ''
    require("guess-indent").setup({})
  '';

  keymaps = [
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
  ];
}
