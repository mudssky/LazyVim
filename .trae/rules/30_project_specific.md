# 📂 30_project_specific.md

> **唯一允许出现项目细节的文件**

## 🛠️ Project Tech Stack
- **Core**: Neovim >= 0.9.0, Lua 5.1/JIT
- **Plugin Manager**: `lazy.nvim`
- **Shell Environment**: PowerShell Core (`pwsh`) - **所有脚本必须兼容 Windows PowerShell**
- **Formatter**: `stylua`
- **Linter**: `selene` (if available)

## 📂 Directory Structure (ASCII Tree)
```text
d:\coding\Projects\neovim\LazyVim\
├── load_lazyvim.ps1       # [Boot] 启动脚本
├── init.lua               # [Entry] 入口文件
├── lua/
│   └── lazyvim/           # 🚫 [Core] Upstream Core (严禁修改)
├── myConfig/              # ✅ [User] 用户配置专区 (由此处接管)
│   ├── lua/
│   │   ├── config/        # Options, Keymaps, Autocmds
│   │   ├── plugins/       # Plugin Specs (Lazy.nvim format)
│   │   └── utils/         # Helper functions
│   └── USER_CONFIG_GUIDE.md
├── scripts/
│   ├── check_myconfig.ps1 # 🛡️ [Verify] 配置验证脚本
│   └── check_lazy.ps1
├── stylua.toml            # [Style] 代码格式化规则
└── selene.toml            # [Lint] 代码检查规则
```

## 🚨 Project Specific Constraints

### 1. Config Scope Isolation
- **Rule**: 用户的自定义配置 **必须且只能** 在 `myConfig/` 目录下进行。
- **Exception**: 严禁直接修改 `lua/lazyvim/`。如果必须修改核心行为，应在 `myConfig` 中使用 `vim.tbl_deep_extend` 或 `lazy.nvim` 的 `opts` 进行覆盖。

### 2. Plugin Specification
- 必须遵循 `lazy.nvim` 的 Spec 格式：
  ```lua
  return {
    "plugin/name",
    event = "VeryLazy", -- 优先使用事件驱动加载
    opts = { ... },     -- 使用 opts 表而不是 config 函数（除非必要）
  }
  ```

### 3. Verification Commands (Strict Execution)
每次修改代码后，**必须** 依次运行以下命令：

1.  **Format Code**:
    ```powershell
    stylua .
    ```
    *(如果 stylua 未安装，提示用户安装或尝试运行，但不强制中断流程，重点是代码正确性)*

2.  **Validate Config**:
    ```powershell
    pwsh scripts/check_myconfig.ps1
    ```
    *(此脚本必须运行且通过，否则视为任务失败)*
