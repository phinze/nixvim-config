# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration using nixvim - a Nix-based framework for declaratively configuring Neovim. All configuration is done through Nix expressions, providing type-safety and reproducibility.

## Key Commands

### Running and Building
- `nix run .` - Run the configured Neovim
- `nix flake check .` - Validate the configuration
- `nix build` - Build the Neovim derivation
- `nix flake show` - Display available flake outputs

### Development Workflow
When modifying the configuration:
1. Edit files in `config/` directory (primarily `config/nixvim.nix`)
2. Run `nix flake check .` to validate changes
3. Test with `nix run .`

## Architecture

### File Structure
- `flake.nix` - Flake definition with nixvim input and multi-platform support
- `config/default.nix` - Entry point that imports configuration modules
- `config/nixvim.nix` - Main configuration file containing all Neovim settings, plugins, and keybindings

### Configuration Patterns
- All plugins are declared in the `plugins` attribute set in `config/nixvim.nix`
- Keybindings follow a consistent pattern using `<leader>` (Space) as the prefix
- LSP servers are configured in `plugins.lsp.servers`
- Formatters are configured through `plugins.conform-nvim`
- Test runners are configured in both `plugins.neotest` and `plugins.vim-test`

### Key Design Decisions
- Leader key is Space
- System clipboard integration is enabled by default
- Format-on-save is enabled with language-specific formatters
- Dual test runner setup: neotest (native) and vim-test (with vimux)
- Git integration through gitsigns, gitlinker, and neogit
- Copilot integration for AI-assisted coding