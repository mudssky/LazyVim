-- -----------------------------------------------------------------------------
-- 文件: utils/vscode/search.lua
-- 描述: VSCode 全局搜索/替换操作封装
-- 依赖: `utils.base` 提供 `vscode_call`
-- -----------------------------------------------------------------------------

local U = require("utils.base")
local M = {}

--[[
功能: 打开全局搜索面板
输入: 无
输出: 无
特殊: 触发 `workbench.action.findInFiles`; 默认阻塞等待
]] --
M.find_in_files = function()
  U.vscode_call("workbench.action.findInFiles")
end

--[[
功能: 打开全局替换面板
输入: 无
输出: 无
特殊: 触发 `workbench.action.replaceInFiles`; UI 命令可在调用处考虑 `{wait=false}`
]] --
M.replace_in_files = function()
  U.vscode_call("workbench.action.replaceInFiles")
end

return M
