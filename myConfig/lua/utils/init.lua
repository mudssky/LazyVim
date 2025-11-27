-- -----------------------------------------------------------------------------
-- 文件: utils/init.lua
-- 描述: 通用工具函数聚合模块
-- 作者: mudssky
-- 更新: 2024
-- -----------------------------------------------------------------------------

local M = require("utils.base")

local vscode_modules = {
  edit = require("utils.vscode.edit"),
  search = require("utils.vscode.search"),
  vscode_origin = function()
    if not M.is_vscode() then return nil end
    local vs = M.safe_require("vscode")
    return vs
  end

}

M.vscode = vscode_modules

return M
