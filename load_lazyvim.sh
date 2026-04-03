#!/usr/bin/env bash
# LazyVim 加载脚本 (Bash 版本)
# 作者: mudssky
# 描述: 使用 dofile 方式加载 LazyVim 项目到 Neovim (Linux/macOS 原生支持)

set -euo pipefail

# 动态计算 LazyVim 路径（基于脚本位置）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAZYVIM_PATH="${SCRIPT_DIR}/lua/lazyvim/init.lua"

# 检查文件是否存在
if [ ! -f "${LAZYVIM_PATH}" ]; then
  echo "错误: LazyVim init.lua 文件不存在: ${LAZYVIM_PATH}" >&2
  exit 1
fi

# 获取 Neovim 配置目录（遵循 XDG 规范）
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"

# 确保配置目录存在
if [ ! -d "${NVIM_CONFIG_DIR}" ]; then
  mkdir -p "${NVIM_CONFIG_DIR}"
  echo "创建 Neovim 配置目录: ${NVIM_CONFIG_DIR}"
fi

# 创建 init.lua 文件路径
INIT_LUA_PATH="${NVIM_CONFIG_DIR}/init.lua"

# 检查是否已存在 init.lua，自动备份
if [ -f "${INIT_LUA_PATH}" ]; then
  BACKUP_PATH="${INIT_LUA_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "${INIT_LUA_PATH}" "${BACKUP_PATH}"
  echo "已备份现有 init.lua 到: ${BACKUP_PATH}"
fi

# 写入新的 init.lua
cat > "${INIT_LUA_PATH}" << LUAEOF
-- LazyVim 自动加载脚本
-- 正确引导 lazy.nvim 和 LazyVim

-- LazyVim目录（由部署脚本动态计算并传入）
local lazyvim_dir = "${SCRIPT_DIR}"

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

-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = "\\\\"

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
local function load_user_config(module_name)
  local ok, err = pcall(require, module_name)
  if not ok then
    -- 忽略模块不存在的错误，但报告语法错误
    if not tostring(err):find("not found") then
      vim.notify("⚠ 用户配置加载失败: " .. module_name .. " (" .. tostring(err) .. ")", vim.log.levels.WARN, { title = "MyConfig" })
    end
  end
  return ok
end

-- 1. 优先加载选项 (Options): 确保 Leader 键和其他核心设置在插件加载前生效
load_user_config("config.options")

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
  -- 2. 延迟加载键位和自动命令 (Keymaps & Autocmds): 确保覆盖插件的默认设置
  load_user_config("config.keymaps")
  load_user_config("config.autocmds")
end)
LUAEOF

echo "LazyVim 加载脚本已创建完成!"
echo "配置文件位置: ${INIT_LUA_PATH}"
echo "LazyVim 路径: ${LAZYVIM_PATH}"
echo ""
echo "现在可以启动 Neovim 来测试 LazyVim 是否正确加载。"
echo "使用命令: nvim"
