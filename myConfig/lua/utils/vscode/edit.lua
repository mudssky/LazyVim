local U = require("utils")
local M = {}
M.close_editor = U.vscode("workbench.action.closeActiveEditor")
M.open_settings = U.vscode("workbench.action.openSettings")
M.toggle_sidebar = U.vscode("workbench.action.toggleSidebarVisibility")
return M
