-- 用户自定义自动命令
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\autocmds.lua
local utils = require("utils")
-- 创建自动命令组
local function augroup(name)
  return vim.api.nvim_create_augroup("myconfig_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- local  lazyvimAuGroup=  'lazyvim_'
-- 配置加载提示（已移除，避免影响启动速度）
-- vim.notify("📝 正在加载用户自定义自动命令配置...", vim.log.levels.INFO, { title = "MyConfig" })

-- 修改lazyvim autocmd 相关配置
local function custom_autocmd()
  local ok, _ = pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
  if not ok then
    print("lazyvim_wrap_spell 不存在")
  end
end
if utils.is_vscode() then
  autocmd('Syntax', {
    group = augroup('wrap_spell'),
    callback = function()
      custom_autocmd()
    end
  })
end
-- 禁用 LazyVim 的拼写检查自动命令组
-- vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- vim.notify("✓ 已禁用 LazyVim 拼写检查自动命令组 (wrap_spell)", vim.log.levels.INFO, { title = "MyConfig" })
