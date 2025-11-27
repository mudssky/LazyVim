-- -----------------------------------------------------------------------------
-- 文件: utils/init.lua
-- 描述: 通用工具函数聚合模块
-- 作者: mudssky
-- 更新: 2024
-- -----------------------------------------------------------------------------

local M = require("utils.base")

-- 获取原始的 vscode 函数
local vscode_func = M.vscode

-- 创建子模块表
local vscode_modules = {
  edit = require("utils.vscode.edit"),
  search = require("utils.vscode.search"),
}

-- 将 M.vscode 替换为一个既可以调用（保持兼容）又包含子模块的 table
M.vscode = setmetatable(vscode_modules, {
  __call = function(_, ...)
    return vscode_func(...)
  end,
  -- 如果将来需要动态加载，可以在这里加 __index
})

return M
