-- 用户自定义键位映射
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\keymaps.lua

-- 配置加载提示
-- vim.notify("⌨️ 正在加载用户自定义键位映射配置...", vim.log.levels.INFO, { title = "MyConfig" })
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

-- vim.notify("✓ 用户自定义键位映射配置加载完成", vim.log.levels.INFO, { title = "MyConfig" })

-- 定义 VSCode 键位映射
local function vscode_keymap()
  if utils.is_vscode() then
    local vscode_call = utils.vscode_call
    local leader_key = "<space>"
    -- whichkey 插件配置
    keymap("n", leader_key, function() vscode_call("whichkey.show") end, { desc = "Show WhichKey" })
    keymap("v", leader_key, function() vscode_call("whichkey.show") end, { desc = "Show WhichKey" })

    --[[
    核心代码导航 (LSP 增强)
    ]]
    -- gf支持文件名,文件路径跳转，通过quickOpen
    keymap('n', 'gf', function()
      local cfile = vim.fn.expand('<cfile>')
      vim.notify("Lua 脚本已捕获: " .. cfile)
      vim.schedule(function()
        vim.notify("VSCode 已触发: workbench.action.quickOpen " .. cfile)
        -- 注意：这里传入 filename 作为参数，VS Code 会把它填入搜索框
        vscode_call('workbench.action.quickOpen', { args = cfile, wait = false })
      end)
    end)
    -- gd: 窥视定义 (Peek Definition) - 不离开当前页面查看定义
    keymap('n', 'gd', function()
      -- wait=false 很重要，因为这只是触发 UI
      vscode_call('editor.action.peekDefinition', { wait = false })
    end)
    -- gD: 跳转定义 (Go to Definition) - 真的跳过去
    keymap('n', 'gD', function()
      vscode_call('editor.action.revealDefinition', { wait = false })
    end)
    -- gr: 窥视引用 (Peek References) - 查看哪里用了这个变量/组件
    keymap('n', 'gr', function()
      vscode_call('editor.action.referenceSearch.trigger', { wait = false })
    end)
    -- gy: 窥视类型定义 (Peek Type Definition) - TS 开发神器
    keymap('n', 'gy', function()
      vscode_call('editor.action.peekTypeDefinition', { wait = false })
    end)
    -- gs (Go Symbol): 当前文件内符号跳转 (@)
    keymap('n', 'gs', function()
      vscode_call('workbench.action.gotoSymbol', { wait = false })
    end)
    -- gS (Go Symbol Workspace): 全局符号跳转 (#) - 比文件名搜索更精准
    -- 如果你记得组件名叫 'UserCard'，但忘了文件名叫 user-card.vue 还是 index.vue，用这个最快
    keymap('n', 'gS', function()
      vscode_call('workbench.action.showAllSymbols', { wait = false })
    end)
  end
end


vscode_keymap()
