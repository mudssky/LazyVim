-- 用户自定义选项设置
-- 文件位置: %LOCALAPPDATA%\nvim\lua\config\options.lua

-- 配置加载提示（已移除，避免影响启动速度）
-- vim.notify("⚙️ 正在加载用户自定义选项配置...", vim.log.levels.INFO, { title = "MyConfig" })
local utils = require("utils")
local opt = vim.opt

-- 终端配置 - Windows 下默认使用 PowerShell 7+
if vim.fn.has("win32") == 1 then
  -- 设置默认 shell 为 PowerShell 7+
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag =
    "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

local function neovide_config()
  if vim.g.neovide then
    vim.o.guifont = "FiraCode_Nerd_Font"
    vim.g.neovide_cursor_vfx_mode = "railgun"
    -- 关闭snack的所有动画
    vim.g.snacks_animate = false
  end
end

neovide_config()

-- 示例：编辑器设置
-- opt.relativenumber = true -- 显示相对行号
-- opt.wrap = false -- 不自动换行
-- opt.scrolloff = 8 -- 光标上下保持8行距离
-- opt.sidescrolloff = 8 -- 光标左右保持8列距离

-- 示例：搜索设置
-- opt.ignorecase = true -- 搜索时忽略大小写
-- opt.smartcase = true -- 智能大小写搜索

-- 示例：缩进设置
-- opt.tabstop = 4 -- Tab 显示为4个空格
-- opt.shiftwidth = 4 -- 自动缩进使用4个空格
-- opt.expandtab = true -- 使用空格代替Tab

-- 示例：外观设置
-- opt.termguicolors = true -- 启用真彩色
-- opt.signcolumn = "yes" -- 始终显示符号列

-- vim.notify("✓ 用户自定义选项配置加载完成", vim.log.levels.INFO, { title = "MyConfig" })
