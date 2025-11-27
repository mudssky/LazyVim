-- -----------------------------------------------------------------------------
-- 文件: utils/vscode/edit.lua
-- 描述: VSCode 编辑器相关操作封装 (关闭、打开设置、切换侧边栏等)
-- 依赖: `utils.base` 提供 `vscode_call` 与环境判断
-- -----------------------------------------------------------------------------

local U = require("utils.base")
local M = {}

--[[
功能: 关闭当前激活的编辑器标签
输入: 无
输出: 无
特殊: 通过 `vscode_call` 触发 `workbench.action.closeActiveEditor` 命令; 默认阻塞等待
]] --
M.close_editor = function()
  U.vscode_call("workbench.action.closeActiveEditor")
end

--[[
功能: 打开 VSCode 设置面板
输入: 无
输出: 无
特殊: 触发 `workbench.action.openSettings`; 无需参数
]] --
M.open_settings = function()
  U.vscode_call("workbench.action.openSettings")
end

--[[
功能: 切换侧边栏可见性
输入: 无
输出: 无
特殊: UI 类命令, 如不需等待可在调用处考虑传入 `{wait=false}`
]] --
M.toggle_sidebar = function()
  U.vscode_call("workbench.action.toggleSidebarVisibility")
end

return M
