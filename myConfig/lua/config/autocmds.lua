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
-- 但是中文输入的情况下还是这些快捷键好用

-- 以下是markdown文件的快捷键设置
-- 设置Ctrl+1到Ctrl+6快捷键用于切换/设置markdown标题级别
-- 在正常模式和插入模式下都可以使用
-- 如果当前行已经是对应级别的标题，则会移除标题标记
-- 如果不是标题或者是其他级别的标题，则会设置为对应级别的标题
-- 例如:
-- 按下Ctrl+1: 普通文本 -> # 一级标题
-- 再次按下Ctrl+1: # 一级标题 -> 普通文本
-- 按下Ctrl+2: # 一级标题 -> ## 二级标题

autocmd('FileType', {
  pattern = 'markdown',
  group = augroup('markdown'),
  callback = function()
    for i = 1, 6 do
      -- 核心逻辑函数，用于计算新的行内容
      local function get_new_line()
        local line = vim.api.nvim_get_current_line()
        -- 匹配行首的'#'号，并捕获它们
        local current_hashes = line:match("^(#+)%s")
        -- 计算当前标题级别，如果没有则为 0
        local current_level = current_hashes and #current_hashes or 0
        -- 移除所有已有的标题标记，得到纯净的文本行
        local clean_line = line:gsub("^(#*)%s*", "")

        -- 如果触发的快捷键级别与当前行标题级别相同
        if current_level == i then
          -- 取消标题，返回纯净文本
          return clean_line
        else
          -- 否则，覆盖为新的标题级别
          local new_heading = string.rep("#", i) .. " "
          return new_heading .. clean_line
        end
      end

      -- 为正常模式 (Normal Mode) 设置快捷键
      vim.keymap.set("n", "<C-" .. i .. ">", function()
        vim.api.nvim_set_current_line(get_new_line())
      end, { buffer = true, desc = "切换/设置 标题 " .. i })

      -- 为插入模式 (Insert Mode) 设置快捷键
      vim.keymap.set("i", "<C-" .. i .. ">", function()
        local new_line = get_new_line()
        vim.api.nvim_set_current_line(new_line)
        -- 将光标移动到标题标记之后，方便立即输入
        local prefix = new_line:match("^(#*)%s*") or ""
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_win_set_cursor(0, { row, #prefix })
      end, { buffer = true, desc = "切换/设置 标题 " .. i })
    end
  end
})

-- 禁用 LazyVim 的拼写检查自动命令组
-- vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- vim.notify("✓ 已禁用 LazyVim 拼写检查自动命令组 (wrap_spell)", vim.log.levels.INFO, { title = "MyConfig" })
