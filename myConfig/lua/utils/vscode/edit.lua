local U = require("utils.base")
local M = {}
M.close_editor = function()
  U.vscode_call("workbench.action.closeActiveEditor")
end
M.open_settings = function()
  U.vscode_call("workbench.action.openSettings")
end
M.toggle_sidebar = function()
  U.vscode_call("workbench.action.toggleSidebarVisibility")
end
return M
