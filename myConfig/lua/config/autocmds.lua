-- 用户自定义自动命令
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\autocmds.lua

-- 创建自动命令组
local function augroup(name)
  return vim.api.nvim_create_augroup("myconfig_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- 配置加载提示
vim.notify("📝 正在加载用户自定义自动命令配置...", vim.log.levels.INFO, { title = "MyConfig" })

-- 禁用 LazyVim 的拼写检查自动命令组
pcall(vim.api.nvim_clear_autocmds, { group = "wrap_spell" })
vim.notify("✓ 已禁用 LazyVim 拼写检查自动命令组 (wrap_spell)", vim.log.levels.INFO, { title = "MyConfig" })
