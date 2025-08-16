-- 用户自定义键位映射
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\keymaps.lua

local keymap = vim.keymap.set

-- 示例：添加自定义键位映射
-- keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
-- keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })

-- 示例：窗口管理快捷键
-- keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
-- keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
-- keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
-- keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
