local U = require("utils.base")
local M = {}
M.find_in_files = function()
  U.vscode_call("workbench.action.findInFiles")
end
M.replace_in_files = function()
  U.vscode_call("workbench.action.replaceInFiles")
end
return M
