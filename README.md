# astrovim-config

Personal [AstroNvim](https://github.com/AstroNvim/AstroNvim) v6 config for Windows, with an in-editor cheat sheet (`Space ?`).

## Install (PowerShell 7, run once)

**1. Tools** (admin shell; [Chocolatey](https://chocolatey.org/install) required)

```powershell
choco install neovim git git-lfs lazygit ripgrep fd powershell-core nerd-fonts-JetBrainsMono -y
```

Then set the terminal font to *JetBrainsMono Nerd Font* and restart the terminal.

**2. Config**

```powershell
git clone https://github.com/Svygzhryr/astrovim-config.git $env:LOCALAPPDATA\nvim-astro
```

**3. PowerShell** (`F7` terminal: git completion and history hints)

```powershell
Install-Module posh-git -Scope CurrentUser -Force
New-Item -Force -ItemType File $PROFILE | Out-Null
Add-Content $PROFILE @'
function astro { $env:NVIM_APPNAME='nvim-astro'; nvim @args; Remove-Item Env:NVIM_APPNAME }
Import-Module posh-git
if ($Host.Name -eq 'ConsoleHost' -and -not [Console]::IsOutputRedirected) {
  try {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
    # the list view garbles nvim's embedded terminal
    Set-PSReadLineOption -PredictionViewStyle $(if ($env:NVIM) { 'InlineView' } else { 'ListView' }) -ErrorAction Stop
  } catch {}
}
'@
```

**4. Git** (recommended for rebase-heavy work)

```powershell
git lfs install
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global rebase.autosquash true
git config --global rerere.enabled true
git config --global core.editor nvim   # `git rebase -i` todo list opens in nvim
```

**5. Start**

```powershell
astro   # first launch installs plugins
```

To use this as the default config instead, clone to `$env:LOCALAPPDATA\nvim` and drop the `astro` function.

## Notes

- `lua/polish.lua` pins `cmd.exe` as nvim's shell: when nvim is started from Git Bash it otherwise picks `bash.exe` with cmd flags, and lazygit / `:!` / terminals die instantly.
- `F7` terminals run `pwsh` (`lua/plugins/toggleterm.lua`).
- Cheat sheet: `Space ?` (fuzzy) or `Space f ?` (full page). Edit entries in `lua/cheatsheet.lua`.
- Update plugins with `Space p u`.
