# LazyVim 加载脚本
# 作者: mudssky
# 创建日期: $(Get-Date -Format 'yyyy-MM-dd')
# 描述: 使用dofile方式加载LazyVim项目到Neovim

# 动态计算LazyVim路径（基于脚本位置）
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LazyVimPath = Join-Path $ScriptDir "lua\lazyvim\init.lua"

# 检查文件是否存在
if (-not (Test-Path $LazyVimPath)) {
  Write-Error "LazyVim init.lua 文件不存在: $LazyVimPath"
  exit 1
}

# 创建Neovim启动脚本内容
$NvimScript = @"
-- LazyVim 自动加载脚本
-- 正确引导 lazy.nvim 和 LazyVim

-- LazyVim目录（由PowerShell脚本动态计算并传入）
local lazyvim_dir = "$($ScriptDir.Replace('\', '\\'))"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 将本地 LazyVim 目录添加到运行时路径
vim.opt.rtp:prepend(lazyvim_dir)

-- 定义项目本地配置目录
local myconfig_dir = lazyvim_dir .. "/myConfig"
vim.opt.rtp:prepend(myconfig_dir)

-- 加载用户自定义配置
pcall(require, "config.options")
pcall(require, "config.keymaps")
pcall(require, "config.autocmds")

-- 设置 lazy.nvim 并加载 LazyVim
require("lazy").setup({
  spec = {
    -- 从本地路径加载 LazyVim
    { dir = lazyvim_dir, import = "lazyvim.plugins" },
    -- 加载用户自定义插件配置
    { import = "plugins" },
  },
  defaults = {
    -- 默认情况下，只有 LazyVim 插件会被延迟加载
    lazy = false,
    -- 总是使用最新的 git commit
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- 自动检查插件更新
  performance = {
    rtp = {
      -- 禁用一些默认插件
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

print("LazyVim 已从本地目录成功加载: " .. lazyvim_dir)
"@

# 获取Neovim配置目录
$NvimConfigDir = "$env:LOCALAPPDATA\nvim"
if (-not (Test-Path $NvimConfigDir)) {
  New-Item -ItemType Directory -Path $NvimConfigDir -Force
  Write-Host "创建Neovim配置目录: $NvimConfigDir"
}

# 创建init.lua文件路径
$InitLuaPath = Join-Path $NvimConfigDir "init.lua"

# 检查是否已存在init.lua
if (Test-Path $InitLuaPath) {
  $BackupPath = "$InitLuaPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
  Copy-Item $InitLuaPath $BackupPath
  Write-Host "已备份现有init.lua到: $BackupPath"
}

# 写入新的init.lua
$NvimScript | Out-File -FilePath $InitLuaPath -Encoding UTF8

Write-Host "LazyVim加载脚本已创建完成!"
Write-Host "配置文件位置: $InitLuaPath"
Write-Host "LazyVim路径: $LazyVimPath"
Write-Host ""
Write-Host "现在可以启动Neovim来测试LazyVim是否正确加载。"
Write-Host "使用命令: nvim"
