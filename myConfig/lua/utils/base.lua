-- -----------------------------------------------------------------------------
-- 文件: utils/base.lua
-- 描述: 通用工具函数基础模块 (Internal)
-- 作者: mudssky
-- -----------------------------------------------------------------------------

local M = {}

-- 已弃用: M.vscode（请使用 M.vscode_call）

-- 检查是否在 VSCode 环境中
M.is_vscode = function()
  return vim.g.vscode ~= nil
end

-- 安全地尝试加载模块
--[[
功能: 安全加载 Lua 模块
输入: `module`(string) 要加载的模块名
输出: 成功返回模块值; 失败返回 nil 并提示错误
特殊: 使用 `pcall(require, ...)` 捕获加载期异常, 通过 `vim.notify` 输出错误
备注: 仅在 Neovim 环境可用, 依赖 `vim.notify` 与 `vim.log.levels`
]]
--
M.safe_require = function(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("无法加载模块: " .. module, vim.log.levels.ERROR)
    return nil
  end
  return result
end

--[[
功能: 调用 VS Code 命令, 支持阻塞/非阻塞两种模式
输入:
  - `command`(string) VS Code 命令 ID, 如 `workbench.action.openSettings`
  - `opts`(table|nil)
      - `args`(any|function|nil) 命令参数, 允许提供函数延迟计算; 计算失败会提示错误
      - `wait`(boolean|nil) 是否阻塞等待 VS Code 返回结果; 未设置时默认为 true
      - `silent`(boolean|nil) 在非 VSCode 环境下是否静默
输出: 成功返回 true, 失败返回 false
特殊:
  - 非阻塞模式通过 `vim.fn.VSCodeNotify` 触发命令, 仅发送不等待返回
  - 阻塞模式需依赖扩展 `vscode.nvim`, 使用其 `action/call` 等待结果
关键流程:
  1) 环境校验: 非 VSCode 环境直接返回
  2) 参数处理: 若 `args` 为函数则安全执行并取返回值
  3) 模式分支: 根据 `wait` 选择通知或阻塞调用
]]
--
M.vscode_call = function(command, opts)
  opts = opts or {}

  -- 1. 环境检查
  if not vim.g.vscode then
    if not opts.silent then
      vim.notify("VSCode 命令只能在 VSCode 环境中使用: " .. command, vim.log.levels.WARN)
    end
    return false
  end

  --[[
  参数处理: 支持以函数形式动态生成命令参数, 以便在调用时计算最新上下文。
  若函数执行失败, 立即提示错误并中止调用。
  ]]
  --
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

  --[[
  调用模式选择:
  - 当 `wait` 为 nil 时默认阻塞, 与历史行为保持一致
  - 当 `wait` 为 false 时走非阻塞通知路径, 适合不会返回值的 UI 类命令
  ]]
  --
  local wait = opts.wait
  if wait == nil then
    wait = true
  end

  if not wait then
    --[[
    非阻塞通知路径:
    - 通过 `VSCodeNotify` 触发命令, 不等待返回值
    - 第二参数为 nil 时会被 VS Code 端忽略
    ]]
    --
    vim.fn.VSCodeNotify(command, args)
  else
    --[[
    阻塞调用路径:
    - 依赖 `vscode.nvim` 扩展, 若不可用则返回失败
    - 无参数时使用 `action`, 有参数时使用 `call`
    ]]
    --
    local vs = M.safe_require("vscode")
    if not vs then
      return false
    end

    if args == nil then
      vs.action(command)
    else
      vs.call(command, args)
    end
  end

  return true
end
-- 检查插件是否可用
--[[
功能: 检查指定插件模块是否可用
输入: `plugin_name`(string) 形如 `telescope`, `bufferline`
输出: 返回 boolean, true 表示可 `require`
特殊: 使用 `pcall(require, ...)` 判断, 不触发加载副作用
]]
--
M.has_plugin = function(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

-- 加载插件配置
--[[
功能: 手动加载插件配置目录下的所有 `*.lua` 并返回规格表
输入: 无 (通过调用栈推断配置根路径)
输出: `plugin_specs`(table) 逐文件返回的配置表组成的数组
特殊:
  - 依赖 `debug.getinfo` 计算调用者路径, 当调用层级变化时需调整 `getinfo` 层级
  - 读取 `<config>/plugins/*.lua` 并以 `dofile` 执行, 捕获失败并告警
关键流程:
  1) 解析配置目录路径
  2) 枚举插件文件
  3) 逐个执行并收集返回值
]]
--
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
