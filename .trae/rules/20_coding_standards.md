# 🛡️ 20_coding_standards.md

> 编码、架构、可维护性与测试

## 🏗️ Architecture Principles
- **SOLID**: 遵循单一职责原则 (SRP)，每个模块/函数只做一件事。
- **Dry (Don't Repeat Yourself)**: 提取公共逻辑到工具函数中。
- **Modularity**: 保持配置和逻辑的模块化，避免巨型文件。

## 📝 Coding Style (Lua / Neovim)
- **Variables**:
    - Local variables: `snake_case`
    - Global/Classes: `PascalCase`
    - Constants: `UPPER_CASE`
- **Functions**:
    - Prefer `local function` over global functions.
    - Return early to avoid deep nesting.
- **Safety**:
    - 使用 `pcall` 或 `xpcall` 包裹可能失败的外部调用。
    - 严禁使用全局变量 `_G`（除非框架强制要求）。

## 🆚 VSCode Compatibility
- **Environment Check**: 任何涉及 UI、终端、快捷键或插件加载的配置，**必须** 使用 `utils.is_vscode()` 进行判断。
    - **Plugin**: 使用 `cond = not require("utils").is_vscode()` 禁用不兼容插件。
    - **Keymap/Option**: 使用 `if not require("utils").is_vscode() then ... end` 包裹仅限 Neovim 的逻辑。

## 🚫 Anti-Patterns
- **No `vim.cmd` abuse**: 优先使用 `vim.opt`, `vim.keymap`, `vim.api` 等 Lua API，避免使用字符串形式的 Vimscript。
- **No Hardcoding**: 路径、魔术数字必须定义为常量或配置项。
- **No Silent Errors**: 禁止空的 `catch` 块，必须记录日志或通知用户。

## 🧪 Testing & Verification Standards
- **Static Analysis**: 必须通过 Linter (Selene/Luacheck) 和 Formatter (Stylua)。
- **Runtime Check**: 关键配置加载必须通过加载测试脚本。
- **Docs**: 复杂的逻辑必须包含简明的中文注释。

## 📦 Commits & Documentation
- **Conventional Commits**:
- **Update Guide**: 修改用户配置后，必须检查是否需要更新对应的说明文档。
