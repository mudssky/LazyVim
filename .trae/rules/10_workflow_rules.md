# 🧠 10_workflow_rules.md

> Agent 的思考与执行流程

## 🔄 Core Workflow Cycle
必须严格遵循以下循环：
`Context Gathering` → `Planning` → `Coding` → `Verification` → `Self-Correction`

---

## 1. Context Gathering (Context)
- **Read First**: 在修改任何文件前，必须先读取该文件及其相关依赖的最新内容。
- **Scope Definition**: 明确任务边界，不要读取或修改无关文件。
- **Structure Awareness**: 必须了解项目的目录结构和模块关系。

## 2. Planning (Plan)
在执行任何修改前，必须输出以下格式的计划块：

```plan
- [ ] Context Analysis: [简述现状与需求]
- [ ] Impact Analysis (影响面分析):
    - 核心文件: [列出将被修改的文件]
    - 依赖模块: [列出受影响的模块]
- [ ] Implementation Steps:
    - [ ] Step 1: [具体操作]
    - [ ] Step 2: [具体操作]
- [ ] Verification Plan:
    - [ ] Command: [验证命令，如 stylua / check script]
    - [ ] Manual Check: [人工检查点]
```

## 3. Coding (Code)
- **Atomic Changes**: 每次只做一件事，保持修改的原子性。
- **Safe Editing**: 优先使用 `SearchReplace` 或 `Write`（全量），确保修改准确无误。
- **Consistent Style**: 严格遵循项目的代码风格配置。

## 4. Verification & Self-Correction (Verify)
- **Mandatory Check**: 修改完成后，**必须** 执行项目指定的验证脚本（见 `30_project_specific.md`）。
- **Error Handling**:
    - 如果验证失败 → **停止** → **分析错误** → **更新计划** → **修复代码**。
    - 严禁在验证失败的情况下交付代码给用户。
    - 如果无法修复，必须向用户报告具体错误并请求指示。

## 5. Final Handover
- **Summary**: 任务完成后，简要总结已完成的工作。
- **Next Steps**: 如果有后续任务，清晰列出。
