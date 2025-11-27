-- -----------------------------------------------------------------------------
-- 文件: utils/base.lua
-- 描述: 通用工具函数基础模块 (Internal)
-- 作者: mudssky
-- 更新: 2024
-- -----------------------------------------------------------------------------

local M = {}

-- 已弃用: M.vscode（请使用 M.vscode_call）

-- 检查是否在 VSCode 环境中
M.is_vscode = function()
  return vim.g.vscode ~= nil
end

-- 安全地尝试加载模块
M.safe_require = function(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("无法加载模块: " .. module, vim.log.levels.ERROR)
    return nil
  end
  return result
end

M.vscode_call = function(command, opts)
  opts = opts or {}
  if not vim.g.vscode then
    if not opts.silent then
      vim.notify("VSCode 命令只能在 VSCode 环境中使用: " .. command, vim.log.levels.WARN)
    end
    return false
  end
  local vs = M.safe_require("vscode")
  if not vs then
    return false
  end
  local args = opts.args
  if type(args) == "function" then
    local ok, res = pcall(args)
    if ok then
      args = res
    else
      vim.notify("VSCode 参数函数执行失败: " .. command, vim.log.levels.ERROR)
      return false
    end
  end
  if args == nil then
    vs.action(command)
  else
    vs.call(command, args)
  end
  return true
end

-- 检查插件是否可用
M.has_plugin = function(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

-- 加载插件配置
M.load_plugin_specs = function()
  -- 获取插件配置目录的绝对路径
  -- 注意：如果调用层级发生变化，这里的 debug.getinfo 可能需要调整。
  -- 假设 load_plugin_specs 仍然被外部直接调用，debug.getinfo(2, "S") 应该指向调用者。
  local config_path = vim.fn.fnamemodify(debug.getinfo(2, "S").source:sub(2), ":p:h:h")
  local plugins_path = config_path .. "/plugins"

  -- 手动加载所有插件配置
  local plugin_specs = {}
  local plugin_files = vim.fn.glob(plugins_path .. "/*.lua", false, true)

  for _, file in ipairs(plugin_files) do
    local plugin_name = vim.fn.fnamemodify(file, ":t:r")
    local ok, plugin_config = pcall(dofile, file)
    if ok and plugin_config then
      table.insert(plugin_specs, plugin_config)
    else
      vim.notify("Failed to load plugin: " .. plugin_name, vim.log.levels.WARN)
    end
  end

  return plugin_specs
end

return M
