-- 用户自定义自动命令
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\autocmds.lua
local utils = require("utils")
-- 创建自动命令组
local function augroup(name)
  return vim.api.nvim_create_augroup("myconfig_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- local  lazyvimAuGroup=  'lazyvim_'
-- 配置加载提示（已移除，避免影响启动速度）
-- vim.notify("📝 正在加载用户自定义自动命令配置...", vim.log.levels.INFO, { title = "MyConfig" })

-- 修改lazyvim autocmd 相关配置
local function custom_autocmd()
  local ok, _ = pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
  if not ok then
    print("lazyvim_wrap_spell 不存在")
  end
end
-- if utils.is_vscode() then
-- 所有模式都关掉拼写检查
autocmd('Syntax', {
  group = augroup('wrap_spell'),
  callback = function()
    custom_autocmd()
  end
})


-- 也可以用lsp的h1代替
-- autocmd('FileType', {
--   pattern = 'markdown',
--   group = augroup('markdown'),
--   callback = function()
--     for i = 1, 6 do
--       local heading = string.rep("#", i) .. " "
--       -- 为正常模式 (Normal Mode) 设置快捷键
--       vim.keymap.set("n", "<C-" .. i .. ">", function()
--         local line = vim.api.nvim_get_current_line()
--         -- 移除已有的标题标记，避免重复添加
--         local clean_line = string.gsub(line, "^#* ", "")
--         vim.api.nvim_set_current_line(heading .. clean_line)
--       end, { buffer = true, desc = "标题 " .. i .. " (Normal)" })

--       -- 为插入模式 (Insert Mode) 设置快捷键
--       vim.keymap.set("i", "<C-" .. i .. ">", function()
--         -- 移动到行首
--         vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 0 })
--         -- 移除已有的标题标记
--         local line = vim.api.nvim_get_current_line()
--         local clean_line = string.gsub(line, "^#* ", "")
--         vim.api.nvim_set_current_line(clean_line)
--         -- 插入新的标题标记
--         vim.api.nvim_put({ heading }, 'c', true, true)
--       end, { buffer = true, desc = "标题 " .. i .. " (Insert)" })
--     end
--   end
-- })

-- 禁用 LazyVim 的拼写检查自动命令组
-- vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- vim.notify("✓ 已禁用 LazyVim 拼写检查自动命令组 (wrap_spell)", vim.log.levels.INFO, { title = "MyConfig" })
