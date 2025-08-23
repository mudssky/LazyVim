# LazyVim 加载脚本
# 作者: mudssky
# 创建日期: $(Get-Date -Format 'yyyy-MM-dd')
# 描述: 使用dofile方式加载LazyVim项目到Neovim

# 动态计算LazyVim路径（基于脚本位置）
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# 使用跨平台路径分隔符
$LazyVimPath = Join-Path $ScriptDir "lua/lazyvim/init.lua"

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
local lazyvim_dir = "$($ScriptDir.Replace('\', '/'))"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local function ensure_lazy()
  local uv = vim.uv or vim.loop
  local function exists(p)
    return uv.fs_stat(p) ~= nil
  end
  local function has_module()
    return exists(lazypath .. "/lua/lazy/init.lua")
  end
  if not exists(lazypath) or not has_module() then
    if exists(lazypath) and not has_module() then
      -- 删除损坏的安装
      pcall(vim.fn.delete, lazypath, "rf")
    end
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
end
ensure_lazy()
vim.opt.rtp:prepend(lazypath)
-- 确保 Lua 搜索路径包含 lazy.nvim
pcall(function()
  package.path = lazypath .. "/lua/?.lua;" .. lazypath .. "/lua/?/init.lua;" .. package.path
end)

-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 将本地 LazyVim 目录添加到运行时路径
vim.opt.rtp:prepend(lazyvim_dir)

-- 定义项目本地配置目录
local myconfig_dir = lazyvim_dir .. "/myConfig"
vim.opt.rtp:prepend(myconfig_dir)
-- 确保 myConfig 的 Lua 路径可被 require 找到
pcall(function()
  package.path = myconfig_dir .. "/lua/?.lua;" .. myconfig_dir .. "/lua/?/init.lua;" .. package.path
end)

-- 加载用户自定义配置（在 LazyVim 之前预加载）
-- local function load_user_config(module_name)
--  local ok, err = pcall(require, module_name)
--  if not ok then
--    vim.notify("⚠ 用户配置加载失败: " .. module_name .. " (" .. tostring(err) .. ")", vim.log.levels.WARN, { title = "MyConfig" })
-- end
--  return ok
-- end

-- load_user_config("config.options")
-- load_user_config("config.keymaps")
-- load_user_config("config.autocmds")

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

-- LazyVim 加载完成后的后处理
vim.schedule(function()
  -- 定义项目本地配置目录
  local myconfig_dir = lazyvim_dir .. "/myConfig"
  vim.opt.rtp:prepend(myconfig_dir)
  -- 确保个人配置在 LazyVim 之后再次应用
  local function post_load_user_config(module_name)
    local ok, err = pcall(require, module_name)
    if not ok then
      vim.notify("⚠ 个人配置后加载失败: " .. module_name .. " (" .. tostring(err) .. ")", vim.log.levels.WARN, { title = "MyConfig" })
    end
  end
  -- 重新加载关键配置以确保覆盖 LazyVim 默认设置
  post_load_user_config("config.options")
  post_load_user_config("config.keymaps")
  post_load_user_config("config.autocmds")
end)
"@

# 获取Neovim配置目录（跨平台兼容）
if ($IsMacOS -or $IsLinux) {
  $NvimConfigDir = "~/.config/nvim"
} else {
  $NvimConfigDir = "$env:LOCALAPPDATA\nvim"
}

# 展开路径中的波浪号
if ($NvimConfigDir.StartsWith("~")) {
  $NvimConfigDir = $NvimConfigDir -replace "^~", $HOME
}

if (-not (Test-Path $NvimConfigDir)) {
  New-Item -ItemType Directory -Path $NvimConfigDir -Force
  Write-Information "创建Neovim配置目录: $NvimConfigDir" -InformationAction Continue
}

# 创建init.lua文件路径
$InitLuaPath = Join-Path $NvimConfigDir "init.lua"

# 检查是否已存在init.lua
if (Test-Path $InitLuaPath) {
  $BackupPath = "$InitLuaPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
  Copy-Item $InitLuaPath $BackupPath
  Write-Information "已备份现有init.lua到: $BackupPath" -InformationAction Continue
}

# 写入新的init.lua
$NvimScript | Out-File -FilePath $InitLuaPath -Encoding UTF8

Write-Information "LazyVim加载脚本已创建完成!" -InformationAction Continue
Write-Information "配置文件位置: $InitLuaPath" -InformationAction Continue
Write-Information "LazyVim路径: $LazyVimPath" -InformationAction Continue
Write-Information "" -InformationAction Continue
Write-Information "现在可以启动Neovim来测试LazyVim是否正确加载。" -InformationAction Continue
Write-Information "使用命令: nvim" -InformationAction Continue