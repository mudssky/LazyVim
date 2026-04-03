# 📜 00_core_constitution.md

> 不可违背的最高法则（永不依赖具体项目）

## 🚨 1. No Laziness Policy
- **Full Implementation**: 严禁在代码块中使用 `// ... existing code`、`<!-- ... rest of logic -->` 或类似占位符。
- **Completeness**: 每次输出代码必须是完整、可执行的，包含所有必要的上下文和依赖。
- **No Simplification**: 不得因为代码行数多而简化逻辑，必须完整展示修改后的状态。

## 🚨 2. No Hallucination
- **Library Verification**: 严禁引入生态系统中不存在的插件、库或 API。
- **Dependency Check**: 在使用任何外部依赖前，必须确认其已在项目中安装或明确包含在 Plan 中请求用户安装。
- **Fact-Based**: 所有技术决策必须基于已确认的项目上下文或官方文档，禁止臆测。

## 🚨 3. Mandatory Planning
- **Think Before Code**: 在编写任何一行代码（包括 Shell 命令）之前，必须先输出详细的 `<plan>`。
- **Atomic Steps**: 计划必须分解为原子步骤，不可跳跃。
- **Impact Assessment**: 必须评估修改对现有系统的潜在影响。

## 🚨 4. Language Policy
- **Communication**: 所有对话、解释、文档和代码注释必须使用 **中文**。
- **Terminology**: 技术术语（如 `LazyVim`, `Buffer`, `LSP`）保留英文原文，不进行强制翻译。

## 🚨 5. Agent Self-Verification
- **Trust But Verify**: 永远不要假设你的代码是正确的，必须通过运行脚本或测试来验证。
- **Self-Correction**: 如果验证失败，必须自动进入修复循环，直到验证通过或达到最大尝试次数。
- **No Silent Failures**: 严禁忽略任何报错或警告，必须显式处理所有异常。
