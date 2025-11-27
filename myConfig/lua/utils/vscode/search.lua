local U = require("utils")
local M = {}
M.find_in_files = U.vscode("workbench.action.findInFiles")
M.replace_in_files = U.vscode("workbench.action.replaceInFiles")
return M
