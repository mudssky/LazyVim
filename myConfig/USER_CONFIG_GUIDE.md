# LazyVim 个人配置指南

本指南说明如何在不影响原始 LazyVim 仓库的情况下添加个人配置。

## 配置结构

本配置系统支持两种配置方式：

### 1. 项目本地配置（推荐）

在 LazyVim 项目目录中的 `myConfig/lua/` 目录：

```
D:\coding\Projects\neovim\LazyVim\
├── myConfig/
│   └── lua/
│       ├── config/
│       │   ├── keymaps.lua     # 自定义键位映射
│       │   └── options.lua     # 自定义选项设置
│       └── plugins/
│           └── example.lua     # 插件配置示例
├── load_lazyvim.ps1        # 加载脚本
└── USER_CONFIG_GUIDE.md    # 本指南
```

### 2. 全局用户配置

在用户的 Neovim 配置目录中：

```
%LOCALAPPDATA%\nvim\
├── init.lua                 # 主配置文件（由脚本生成）
├── lua/
│   ├── config/
│   │   ├── keymaps.lua     # 自定义键位映射
│   │   └── options.lua     # 自定义选项设置
│   └── plugins/
│       └── example.lua     # 插件配置示例
└── lazy-lock.json          # 插件版本锁定文件
```

## 配置优先级

1. **项目本地配置** (`myConfig/lua/`) - 最高优先级
2. **全局用户配置** (`%LOCALAPPDATA%\nvim\lua/`) - 次优先级
3. **LazyVim 默认配置** - 最低优先级

项目本地配置可以完全覆盖 LazyVim 的默认设置。

## 如何添加插件配置

### 1. 添加新插件

在 `myConfig/lua/plugins/` 目录下创建 `.lua` 文件：

```lua
return {
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({
        -- 你的配置
      })
    end,
  },
}
```

### 2. 覆盖现有插件配置

```lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        width = 35,  -- 覆盖默认宽度
        position = "left",
      },
    },
  },
}
```

### 3. 禁用插件

```lua
return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
}
```

## 自定义键位映射

在 `myConfig/lua/config/keymaps.lua` 中添加：

```lua
local map = vim.keymap.set

-- 文件操作
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })

-- 窗口管理
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
```

## 自定义选项设置

在 `myConfig/lua/config/options.lua` 中添加：

```lua
local opt = vim.opt

-- 编辑器设置
opt.relativenumber = true
opt.wrap = false
opt.scrolloff = 8

-- Windows 终端设置
if vim.fn.has("win32") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
  opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
end
```

## 配置加载顺序

1. LazyVim 基础配置
2. 用户自定义选项 (`config.options`)
3. 用户自定义键位映射 (`config.keymaps`)
4. 插件系统初始化
5. 用户自定义插件配置 (`plugins/*`)

## 更新 LazyVim

当需要更新 LazyVim 时：

1. 备份你的 `myConfig` 目录
2. 拉取最新的 LazyVim 代码：
   ```bash
   git pull origin main
   ```
3. 重新运行加载脚本：
   ```powershell
   .\load_lazyvim.ps1
   ```
4. 你的个人配置会自动保留

## 最佳实践

### 1. 代码分离
- 将不同类型的配置分别放在不同文件中
- 使用描述性的文件名
- 添加适当的注释

### 2. 版本控制
- 可以将 `myConfig` 目录单独进行版本控制
- 在 `.gitignore` 中排除 `lazy-lock.json`

### 3. 模块化配置
- 将复杂的插件配置拆分为多个文件
- 使用 `require()` 来组织代码

### 4. 测试配置
- 在修改配置后测试 Neovim 启动
- 使用 `:checkhealth` 检查配置状态

## 故障排除

### 1. 配置不生效
- 检查文件路径是否正确
- 确认 Lua 语法无误
- 查看 Neovim 启动时的错误信息

### 2. 插件冲突
- 检查是否有重复的插件配置
- 确认插件依赖关系
- 使用 `:Lazy` 命令查看插件状态

### 3. 键位映射冲突
- 使用 `:map` 命令查看当前映射
- 检查是否有重复的键位定义
- 考虑使用不同的前缀键

## 示例配置

### 完整的插件配置示例

```lua
-- myConfig/lua/plugins/my-plugins.lua
return {
  -- 添加新插件
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup({
        -- 配置选项
      })
    end,
  },
  
  -- 覆盖现有配置
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.95,
          height = 0.85,
        },
      },
    },
  },
  
  -- 禁用不需要的插件
  {
    "folke/flash.nvim",
    enabled = false,
  },
}
```

### 完整的键位映射示例

```lua
-- myConfig/lua/config/keymaps.lua
local map = vim.keymap.set

-- 取消默认键位
vim.keymap.del("n", "<leader>l")

-- 文件操作
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save File" })

-- 缓冲区操作
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

-- 窗口操作
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
map("n", "<leader>wh", "<cmd>split<cr>", { desc = "Horizontal Split" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close Window" })
```

---

通过这种配置方式，你可以：
- ✅ 保持 LazyVim 的最新更新
- ✅ 添加个人定制配置
- ✅ 避免配置冲突
- ✅ 轻松备份和迁移配置
- ✅ 在 Windows 下使用 PowerShell 7+ 作为默认终端

如有问题，请检查 Neovim 的错误信息或查阅相关插件文档。