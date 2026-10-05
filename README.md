# astrovim-config

Personal [AstroNvim](https://github.com/AstroNvim/AstroNvim) v6 config for Windows, with an in-editor cheat sheet.

## Requirements

- Neovim 0.11+ and Git
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal
- `ripgrep` and `fd` for search
- `lazygit` for the git UI: `winget install JesseDuffield.lazygit`

## Install

PowerShell:

```powershell
git clone https://github.com/Svygzhryr/astrovim-config.git $env:LOCALAPPDATA\nvim-astro
[Environment]::SetEnvironmentVariable("NVIM_APPNAME", "nvim-astro", "User")  # restart the terminal after
nvim
```

Plugins install on first launch. To make this your default config instead, clone to `$env:LOCALAPPDATA\nvim` and skip the `NVIM_APPNAME` line.

## Use

- `Space ?` opens the cheat sheet (fuzzy search); `Space f ?` opens the full page.
- Add or edit entries in `lua/cheatsheet.lua`.
- Update plugins with `Space p u`.
