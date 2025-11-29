# Project Rules: LazyVim Fork & Custom Configuration

## 🚨 Critical Instructions (最高指令)

- **No Laziness**: 严禁在代码块中使用 `// ... existing code` 或 `// ... implement logic here`。必须输出完整、可执行的代码。
- **No Hallucination**: 严禁引入 `lazy.nvim` 生态系统中不存在的插件或库。如需引入新插件，必须先请求用户许可。
- **Language**: 所有代码注释、文档和解释必须使用 **中文**。
- **Config Scope**: 用户的自定义配置 **必须** 仅在 `myConfig/` 目录下进行。严禁直接修改 `lua/lazyvim/` 目录下的核心文件（除非是为了修复 upstream bug 并提交 PR）。

## 🧠 Chain of Thought & Planning (思考与规划)

在编写任何代码之前，必须在一个代码块中输出 `<plan>` 标签包裹的计划：

```plan
- [ ] 分析需求与当前代码库结构
- [ ] Impact Analysis (影响面分析):
    - 修改文件: [列出文件路径]
    - 受影响模块: [列出模块]
- [ ] 编写/修改代码
- [ ] 验证: 运行 Stylua 和 Check 脚本
```

## 🛠 Tech Stack & Coding Standards (技术与规范)

- **Core**: Neovim >= 0.9.0, Lua 5.1/JIT.
- **Plugin Manager**: `lazy.nvim`.
- **Shell**: PowerShell Core (`pwsh`) for scripts.
- **Naming Convention**:
    - Files: `snake_case.lua` (e.g., `my_plugin.lua`).
    - Variables: `snake_case` (local), `PascalCase` (classes/meta-tables).
    - Plugin Specs: Return a table or a function returning a table.
- **Preferred Patterns**:
    - Use `vim.tbl_deep_extend` for merging configs.
    - Use `lazy = true` or event-based loading where possible.
    - Modularize configs in `myConfig/lua/plugins/`.
- **Anti-patterns**:
    - Do not use global variables (`_G`) unless absolutely necessary.
    - Do not use `vim.cmd` for options that have `vim.opt` equivalents.

## ⚡ Development Workflow (严格执行流)

1.  **Context Gathering**:
    - 必须先读取 `myConfig/` 下的相关文件。
    - 确认 `load_lazyvim.ps1` 的加载逻辑（如果涉及启动流程）。

2.  **Coding**:
    - 在 `myConfig/lua/` 下进行原子化修改。
    - 遵循 `LazyVim` 的插件 spec 格式。

3.  **Self-Correction (必选)**:
    - 修改后，**必须** 运行以下命令验证：
        - Format: `stylua .` (假定环境中有 stylua，如无则提示用户)
        - Validate: `pwsh scripts/check_myconfig.ps1`
    - 如果 `check_myconfig.ps1` 失败，必须修复直到通过。

4.  **Documentation**:
    - 如果添加了新插件，更新 `myConfig/USER_CONFIG_GUIDE.md`（如果存在）或创建说明。

## 📂 Project Structure Guide

```text
d:\coding\Projects\neovim\LazyVim\
├── load_lazyvim.ps1       # Bootstrapper script
├── init.lua               # Entry point
├── lua/
│   └── lazyvim/           # 🚫 Upstream Core (Do not edit)
├── myConfig/              # ✅ User Configuration Zone
│   ├── lua/
│   │   ├── config/        # Options, Keymaps, Autocmds
│   │   ├── plugins/       # User Plugins specs
│   │   └── utils/         # Helper functions
│   └── USER_CONFIG_GUIDE.md
├── scripts/
│   ├── check_myconfig.ps1 # Validation script
│   └── check_lazy.ps1
├── stylua.toml            # Formatting rules
└── selene.toml            # Linting rules
```

## 📝 Documentation & Maintenance

- **Commits**: Follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).
- **Updates**: Keep `myConfig` decoupled from `lazyvim` core to ensure easy updates from upstream.
