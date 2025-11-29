## 根因分析
- 报错来源：`Executable js-debug-adapter not found`，`pwa-node` 适配器在启动时无法找到 `js-debug-adapter` 可执行。
- 现有定义：`lua/lazyvim/plugins/extras/lang/typescript.lua:239` 使用 `executable.command = "js-debug-adapter"`，依赖该命令在 `PATH` 中可见。
- Windows 环境常见原因：
  - Mason 未安装 `js-debug-adapter` 或安装失败。
  - Neovim 会话/系统 `PATH` 未包含 Mason `bin`（通常位于 `.../nvim-data/mason/bin`）。
  - `nvim-dap`/`mason-nvim-dap` 未生效或被覆盖为未安装适配器。

## 解决方案概述
- 方案A（推荐）：在 `myConfig` 中对 `nvim-dap` 适配器进行覆盖，使用 Mason Registry 解析出 `js-debug-adapter` 的绝对路径（在 Windows 自动使用 `.cmd`），不依赖 `PATH`。
- 方案B（辅助手段）：在 Neovim 会话启动时把 Mason `bin` 注入到 `vim.env.PATH`，保障命令可被发现（仅 Neovim 内有效）。
- 方案C（环境修复）：通过 Mason 安装或重新安装 `js-debug-adapter`，并检查 `tsx`/`ts-node` 以支持 TS 运行（`typescript.lua:271` 会优先选 `tsx`）。

## 具体实施步骤
### 步骤1：新增 `myConfig` DAP 适配器覆盖（无侵入）
- 新建 `myConfig/lua/plugins/dap_js.lua`，覆盖并完善 `pwa-node/node/chrome/msedge` 适配器：
```plan
- [ ] 分析需求与当前代码库结构
- [ ] Impact Analysis (影响面分析):
    - 修改文件: [myConfig/lua/plugins/dap_js.lua]
    - 受影响模块: [nvim-dap, mason.nvim, TypeScript/JavaScript 调试]
- [ ] 编写/修改代码
- [ ] 验证: 运行 Stylua 和 Check 脚本
```
- 拟添加代码（覆盖 `executable.command` 为 Mason 解析出的绝对路径，含 Windows `.cmd` 自动选择）：
```
return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      local registry = require("mason-registry")
      local pkg = registry.get_package("js-debug-adapter")
      local bin = pkg:get_install_path() .. "/bin"
      local cmd = bin .. "/js-debug-adapter"
      if vim.fn.has("win32") == 1 and vim.loop.fs_stat(cmd .. ".cmd") then
        cmd = cmd .. ".cmd"
      end
      for _, t in ipairs({ "node", "chrome", "msedge" }) do
        local pwa = "pwa-" .. t
        dap.adapters[pwa] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = { command = cmd, args = { "${port}" } },
        }
        dap.adapters[t] = function(cb, config)
          local native = dap.adapters[pwa]
          config.type = pwa
          if type(native) == "function" then native(cb, config) else cb(native) end
        end
      end
      local fts = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = fts
      vscode.type_to_filetypes["pwa-node"] = fts
      for _, ft in ipairs(fts) do
        if not dap.configurations[ft] then
          local runtime = nil
          if ft:find("typescript") then runtime = vim.fn.executable("tsx") == 1 and "tsx" or "ts-node" end
          dap.configurations[ft] = {
            {
              type = "pwa-node", request = "launch", name = "Launch file",
              program = "${file}", cwd = "${workspaceFolder}", sourceMaps = true,
              runtimeExecutable = runtime,
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            },
            {
              type = "pwa-node", request = "attach", name = "Attach",
              processId = require("dap.utils").pick_process, cwd = "${workspaceFolder}", sourceMaps = true,
              runtimeExecutable = runtime,
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            },
          }
        end
      end
    end,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "js-debug-adapter")
        end,
      },
    },
  },
}
```

### 步骤2：可选 PATH 注入（仅会话内）
- 在 `myConfig/lua/config/init.lua` 追加：
```
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ";" .. (vim.env.PATH or "")
end
```

### 步骤3：安装与运行时依赖确认
- 在 Neovim 中执行：打开 `:Mason`，确保 `js-debug-adapter` 已安装（必要时重新安装）。
- 项目内安装 TS 运行器：`tsx` 或 `ts-node`（至少其一），例如在项目根：
  - `npm i -D tsx` 或 `npm i -D ts-node typescript`
- 运行 `:checkhealth` 确认 DAP、Node 环境正常。

## 验证步骤
- 运行格式化与检查：
  - `stylua .`
  - `pwsh scripts/check_myconfig.ps1`
- 在一个 TS/JS 文件中：
  - 设置断点。
  - 执行 `:lua require('dap').continue()` 或使用 LazyVim 绑定键位启动 Debug。
  - 验证能够正常启动 `pwa-node` 会话，不再出现 `ENOENT`。

## 回退与兼容
- 若仍出现找不到命令：
  - 手动定位 `js-debug-adapter` 路径：`$env:LOCALAPPDATA\\nvim-data\\mason\\bin\\js-debug-adapter.cmd` 是否存在；不存在则重新安装。
  - 确认 `mfussenegger/nvim-dap` 与 `jay-babu/mason-nvim-dap.nvim` 已加载（`lang.typescript` 与 `dap-core` 均为可选插件，需确保启用）。

## 代码位置参考
- 适配器命令定义位置：`lua/lazyvim/plugins/extras/lang/typescript.lua:239`（`command = "js-debug-adapter"`）。
- VSCode 类型映射：`lua/lazyvim/plugins/extras/lang/typescript.lua:263–266`。
- TS 运行器自动选择：`lua/lazyvim/plugins/extras/lang/typescript.lua:271`。
