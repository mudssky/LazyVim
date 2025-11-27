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

    -- 支持文件名跳转
    keymap('n', 'gf', function()
      local cfile = vim.fn.expand('<cfile>')
      vim.notify("Lua 脚本已捕获: " .. cfile)
      vim.schedule(function()
        vim.notify("VSCode 已触发: workbench.action.quickOpen " .. cfile)
        -- 注意：这里传入 filename 作为参数，VS Code 会把它填入搜索框
        vscode_call('workbench.action.quickOpen', { args = { cfile } })
      end)
    end)
  end
end


vscode_keymap()
