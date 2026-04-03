-- 用户自定义自动命令
-- 文件位置: myConfig/lua/config/autocmds.lua

-- 创建自动命令组
local function augroup(name)
  return vim.api.nvim_create_augroup("myconfig_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- VeryLazy 后处理：在 LazyVim 完成初始化后执行的一次性配置
-- 解决上游 LazyVim 的延迟 clipboard 恢复机制覆盖用户设置的问题
-- ============================================================================
autocmd("User", {
  pattern = "VeryLazy",
  group = augroup("post_init"),
  once = true,
  callback = function()
    -- 1) 禁用 LazyVim 拼写检查自动命令组
    pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

    -- 2) SSH 环境下配置 OSC 52 剪贴板协议（需要 Neovim 0.10+）
    local is_ssh = os.getenv("SSH_CONNECTION") ~= nil or os.getenv("SSH_CLIENT") ~= nil
    if is_ssh and vim.fn.has("nvim-0.10") == 1 then
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
          ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
          ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
          ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
        },
      }
    end

    -- 3) 确保始终使用系统剪贴板寄存器 (+)
    -- 必须在此时机设置，否则会被上游 LazyVim 的 lazy_clipboard 恢复机制覆盖
    vim.opt.clipboard = "unnamedplus"
  end,
})

-- ============================================================================
-- Markdown 标题快捷键
-- 设置 Ctrl+1 到 Ctrl+6 快捷键用于切换/设置 markdown 标题级别
-- 在正常模式和插入模式下都可以使用
-- 例如:
--   按下 Ctrl+1: 普通文本 -> # 一级标题
--   再次按下 Ctrl+1: # 一级标题 -> 普通文本
--   按下 Ctrl+2: # 一级标题 -> ## 二级标题
-- ! 注意，可能会和终端或者 vscode 终端的快捷键冲突导致不生效
-- ============================================================================
autocmd("FileType", {
  pattern = "markdown",
  group = augroup("markdown"),
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
  end,
})
