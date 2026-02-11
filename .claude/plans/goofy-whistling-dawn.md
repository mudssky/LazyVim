# LazyVim myConfig 配置优化方案

## Context

当前 myConfig 配置存在以下核心问题：剪贴板配置与上游 LazyVim 存在时序冲突导致 SSH 环境下配置失效、存在多处死代码和冗余模块、缺少 Linux 原生部署脚本、以及若干代码质量问题。本方案旨在逐项修复这些问题，提升配置的健壮性和可维护性。

---

## 优化项一览

| 优先级 | 编号 | 优化内容 | 涉及文件 |
|--------|------|----------|----------|
| 🔴 高 | 1 | 修复剪贴板配置被上游覆盖的时序问题 | `config/options.lua`, `config/autocmds.lua` |
| 🔴 高 | 2 | 删除未使用的 `has_plugin()` 和 `load_plugin_specs()` | `utils/base.lua` |
| 🔴 高 | 3 | 新建 `load_lazyvim.sh` Bash 部署脚本 | 新文件 `load_lazyvim.sh` |
| 🟡 中 | 4 | VSCode 模块延迟加载（非 VSCode 环境不加载） | `utils/init.lua` |
| 🟡 中 | 5 | 清理或激活 vscode/edit.lua、vscode/search.lua 死代码 | `utils/vscode/*.lua`, `config/keymaps.lua` |
| 🟡 中 | 6 | 优化拼写检查禁用方式（改用 VeryLazy 一次性执行） | `config/autocmds.lua` |
| 🟡 中 | 7 | 移除 keymaps.lua 中 gf 映射的调试 notify | `config/keymaps.lua` |
| 🟡 中 | 8 | 添加 pwsh 存在性检查 | `config/options.lua` |
| 🟢 低 | 9 | 删除空模板 `plugins/example.lua` | `plugins/example.lua` |
| 🟢 低 | 10 | 修正注释中过时的 Windows 路径 | 多文件 |
| 🟢 低 | 11 | 清理 yazi.lua 冗余 netrw 禁用代码 | `plugins/yazi.lua` |

---

## 详细方案

### 1. [高] 修复剪贴板配置时序冲突

**问题**：myConfig `options.lua` 在 `lazy.setup()` 之前加载，设置了 `clipboard = "unnamedplus"` 和 OSC 52。但上游 LazyVim 在 `M.init()` 中（lazy.setup 内部）执行了：
```
M.load("options")  →  opt.clipboard = SSH_TTY ? "" : "unnamedplus"
lazy_clipboard = vim.opt.clipboard:get()  // SSH下保存""
vim.opt.clipboard = ""  // 清空
// ... VeryLazy 事件中恢复 lazy_clipboard（即""）
```
结果：SSH 环境下 myConfig 的 `clipboard = "unnamedplus"` 被覆盖为 `""`。

**修复**：将剪贴板配置从 `options.lua` 移到 `autocmds.lua`，在 VeryLazy 事件**之后**执行：

```lua
-- autocmds.lua 中添加
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    -- SSH 环境下配置 OSC 52
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
    -- 确保始终使用系统剪贴板
    vim.opt.clipboard = "unnamedplus"
  end,
})
```

从 `options.lua` 中移除第 53-73 行（SSH 检测 + OSC 52 + clipboard 设置）。

### 2. [高] 删除 `utils/base.lua` 中的死代码

**删除 `has_plugin()`**（第 119-130 行）：
- 整个 myConfig 中零调用
- `pcall(require, ...)` 会真正执行模块加载，有副作用
- LazyVim 已提供 `LazyVim.has()` 替代

**删除 `load_plugin_specs()`**（第 132-168 行）：
- 整个 myConfig 中零调用
- 依赖 `debug.getinfo` 脆弱设计
- `lazy.nvim` 的 `{ import = "plugins" }` 已自动处理

### 3. [高] 新建 Bash 部署脚本

当前只有 PowerShell 版本，在纯 Linux 环境下需要额外安装 pwsh。新建 `load_lazyvim.sh`，实现与 `load_lazyvim.ps1` 相同的逻辑：
- 动态计算项目路径
- 生成 `~/.config/nvim/init.lua`（尊重 `$XDG_CONFIG_HOME`）
- 备份已有 init.lua
- 嵌入与 ps1 版本相同的 Lua 启动代码

### 4. [中] VSCode 模块延迟加载

**文件**：`utils/init.lua`

当前第 22-24 行无条件 `require("utils.vscode.edit")` 和 `require("utils.vscode.search")`。改为条件加载：

```lua
if M.is_vscode() then
  M.vscode = {
    edit = require("utils.vscode.edit"),
    search = require("utils.vscode.search"),
    vscode_origin = function() ... end,
  }
else
  M.vscode = {}
end
```

### 5. [中] 清理或激活 VSCode 操作封装

`utils/vscode/edit.lua` 定义了 3 个函数、`search.lua` 定义了 2 个函数，全部零调用。

**方案 A（推荐 — 激活使用）**：在 `keymaps.lua` 的 VSCode 区块中为这些操作注册快捷键：
```lua
keymap("n", "<leader>q", utils.vscode.edit.close_editor, { desc = "Close Editor" })
keymap("n", "<leader>,", utils.vscode.edit.open_settings, { desc = "Open Settings" })
keymap("n", "<leader>e", utils.vscode.edit.toggle_sidebar, { desc = "Toggle Sidebar" })
keymap("n", "<leader>sf", utils.vscode.search.find_in_files, { desc = "Find in Files" })
keymap("n", "<leader>sr", utils.vscode.search.replace_in_files, { desc = "Replace in Files" })
```

**方案 B（简化）**：如果确认不需要这些功能，直接删除 `utils/vscode/` 目录。

### 6. [中] 优化拼写检查禁用

当前在每次 `FileType` 事件都 `vim.schedule + pcall` 删除 augroup，效率低。改为 VeryLazy 一次性执行：

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
  end,
})
```

### 7. [中] 移除 gf 映射中的调试 notify

`keymaps.lua` 第 40、42 行有两个调试用的 `vim.notify`，应移除：
```lua
-- 删除这两行：
vim.notify("Lua 脚本已捕获: " .. cfile)
vim.notify("VSCode 已触发: workbench.action.quickOpen " .. cfile)
```

### 8. [中] Windows pwsh 存在性检查

`options.lua` 第 10-19 行直接设置 `shell = "pwsh"`，如果未安装 pwsh 会导致所有 shell 命令失败：

```lua
if vim.fn.has("win32") == 1 then
  if vim.fn.executable("pwsh") == 1 then
    vim.opt.shell = "pwsh"
    -- 现有 shellcmdflag 等配置...
  end
end
```

### 9. [低] 删除空模板 `plugins/example.lua`

全注释内容返回空表，模板信息已在 `USER_CONFIG_GUIDE.md` 中。删除此文件减少 lazy.nvim 不必要的加载。

### 10. [低] 修正注释中过时路径

以下文件第 2 行的路径注释 `%LOCALAPPDATA%\nvim\lua\...` 应更新为实际路径：
- `config/options.lua` → `myConfig/lua/config/options.lua`
- `config/keymaps.lua` → `myConfig/lua/config/keymaps.lua`
- `config/autocmds.lua` → `myConfig/lua/config/autocmds.lua`

### 11. [低] 清理 yazi.lua 冗余 netrw 禁用

`yazi.lua` 的 `init` 函数设置 `vim.g.loaded_netrwPlugin = 1`，但 `load_lazyvim.ps1` 中 `performance.rtp.disabled_plugins` 已包含 `"netrwPlugin"`。且 `open_for_directories = false`，无需此配置。移除 `init` 函数。

---

## 验证方案

1. **SSH 环境剪贴板**：在 SSH 连接下启动 nvim，执行 `:echo &clipboard` 确认为 `unnamedplus`，执行 `:echo vim.g.clipboard.name` 确认为 `OSC 52`
2. **正常启动**：本地启动 nvim，确认无报错，`:checkhealth` 通过
3. **VSCode 环境**：在 VSCode 中打开文件，确认 WhichKey 和 LSP 导航快捷键正常
4. **Bash 部署**：执行 `bash load_lazyvim.sh`，确认 `~/.config/nvim/init.lua` 正确生成
5. **Markdown 标题**：打开 .md 文件，测试 Ctrl+1~6 标题切换功能
6. **延迟加载**：在非 VSCode 终端中执行 `:lua print(vim.inspect(require("utils").vscode))`，确认返回空表
