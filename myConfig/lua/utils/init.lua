-- -----------------------------------------------------------------------------
-- 文件: utils/init.lua
-- 描述: 通用工具函数聚合模块
-- 作者: mudssky
-- -----------------------------------------------------------------------------

--[[
功能: 聚合基础工具与 VSCode 相关子模块, 提供统一入口 `require("utils")`
说明: 本模块在 `utils.base` 之上扩展 `vscode` 命名空间, 以便在 VSCode 环境下调用
]] --
local M = require("utils.base")

--[[
命名空间: `M.vscode`
包含:
  - `edit`   编辑器操作集合 (开关侧边栏、打开设置、关闭编辑器等)
  - `search` 搜索操作集合 (文件内查找/替换)
  - `vscode_origin()` 返回原生 `vscode.nvim` 扩展对象, 非 VSCode 环境返回 nil
]] --
local vscode_modules = {
  edit = require("utils.vscode.edit"),
  search = require("utils.vscode.search"),
  --[[
  功能: 获取原生 `vscode.nvim` 扩展对象
  输入: 无
  输出: VSCode 扩展对象或 nil
  特殊: 仅在 VSCode 环境(`vim.g.vscode`存在)下返回有效对象
  ]] --
  vscode_origin = function()
    if not M.is_vscode() then return nil end
    local vs = M.safe_require("vscode")
    return vs
  end

}

M.vscode = vscode_modules

return M
