-- 用户自定义键位映射
-- 文件位置: myConfig/lua/config/keymaps.lua

local utils = require("utils")
local keymap = vim.keymap.set

-- 示例：添加自定义键位映射
-- keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
-- keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })

-- 示例：窗口管理快捷键
-- keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
-- keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
-- keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
-- keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- ============================================================================
-- VSCode Neovim 扩展键位映射
-- ============================================================================
if utils.is_vscode() then
  local vscode_call = utils.vscode_call

  -- WhichKey 插件配置
  keymap("n", "<space>", function()
    vscode_call("whichkey.show")
  end, { desc = "Show WhichKey" })
  keymap("v", "<space>", function()
    vscode_call("whichkey.show")
  end, { desc = "Show WhichKey" })

  --[[
  核心代码导航 (LSP 增强)
  ]]
  -- gf: 文件名/文件路径跳转，通过 quickOpen
  keymap("n", "gf", function()
    local cfile = vim.fn.expand("<cfile>")
    vim.schedule(function()
      vscode_call("workbench.action.quickOpen", { args = cfile, wait = false })
    end)
  end)
  -- gd: 窥视定义 (Peek Definition) - 不离开当前页面查看定义
  keymap("n", "gd", function()
    vscode_call("editor.action.peekDefinition", { wait = false })
  end)
  -- gD: 跳转定义 (Go to Definition) - 真的跳过去
  keymap("n", "gD", function()
    vscode_call("editor.action.revealDefinition", { wait = false })
  end)
  -- gr: 窥视引用 (Peek References) - 查看哪里用了这个变量/组件
  keymap("n", "gr", function()
    vscode_call("editor.action.referenceSearch.trigger", { wait = false })
  end)
  -- gy: 窥视类型定义 (Peek Type Definition) - TS 开发神器
  keymap("n", "gy", function()
    vscode_call("editor.action.peekTypeDefinition", { wait = false })
  end)
  -- gs (Go Symbol): 当前文件内符号跳转 (@)
  keymap("n", "gs", function()
    vscode_call("workbench.action.gotoSymbol", { wait = false })
  end)
  -- gS (Go Symbol Workspace): 全局符号跳转 (#) - 比文件名搜索更精准
  keymap("n", "gS", function()
    vscode_call("workbench.action.showAllSymbols", { wait = false })
  end)

  --[[
  编辑器操作 (utils.vscode.edit)
  ]]
  keymap("n", "<leader>bx", function()
    utils.vscode.edit.close_editor()
  end, { desc = "Close Editor" })
  keymap("n", "<leader>,", function()
    utils.vscode.edit.open_settings()
  end, { desc = "Open Settings" })
  keymap("n", "<leader>e", function()
    utils.vscode.edit.toggle_sidebar()
  end, { desc = "Toggle Sidebar" })

  --[[
  搜索操作 (utils.vscode.search)
  ]]
  keymap("n", "<leader>sf", function()
    utils.vscode.search.find_in_files()
  end, { desc = "Find in Files" })
  keymap("n", "<leader>sr", function()
    utils.vscode.search.replace_in_files()
  end, { desc = "Replace in Files" })
end
