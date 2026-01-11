# GChat CLI 功能收敛文档

**版本**: v4.0
**日期**: 2025-01-03
**仓库**: https://github.com/mason0510/gchat-cli

---

## 1. 项目概述

GChat CLI 是一个功能完整的 Gemini 命令行对话工具，支持多轮会话、Function Calling、模型降级等高级特性。

### 核心特性

| 特性 | 状态 | 说明 |
|------|------|------|
| 交互式对话 | ✅ | 支持多轮对话、会话管理 |
| 单次提问 | ✅ | CLI 集成，适合脚本调用 |
| Function Calling | ✅ | 支持 weather/search/calculator/bash 工具 |
| 模型降级 | ✅ | gemini-3 失败自动降级到 gemini-2.5 |
| 多后端支持 | ✅ | google/local/nexus/official |
| 会话管理 | ✅ | 自动保存/加载历史 |
| 图片支持 | ✅ | 支持拖拽图片路径 |

---

## 2. 命令结构

```
gchat-cli/
├── bin/
│   ├── gchat          # 主程序 (默认: gemini-3-pro-preview)
│   └── gflashchat     # 快速版 (gemini-3-flash-preview)
├── install.sh         # 安装脚本
└── docs/
    └── GCHAT-CONVERGENCE.md  # 本文档
```

---

## 3. 后端配置

### 3.1 可用后端

| 后端 | URL | Function Calling | 认证 |
|------|-----|------------------|------|
| **google** | `https://google-api.aihang365.com` | ✅ | 无需 |
| local | `http://82.29.54.80:8100` | ❌ | 无需 |
| nexus | `https://nexusai.aihang365.com` | ❌ | Bearer Token |
| official | `https://gemini-official.aihang365.com` | ✅ | GEMINI_API_KEY |

### 3.2 切换后端

```bash
# 方法1: 命令行参数
gchat -b local           # 使用本地后端
gchat -b google          # 使用 google 后端 (默认)
gchat -b official        # 使用官方后端 (需 API Key)

# 方法2: 交互模式
You> /backend google
```

### 3.3 自定义后端

编辑 `bin/gchat` 中的 `BACKENDS` 配置：

```python
BACKENDS = {
    "custom": {
        "url": "https://your-api.com/v1/chat/completions",
        "key": "your-api-key",           # 可选，如果需要认证
        "name": "Custom API",
        "supports_tools": True,          # 是否支持 Function Calling
    },
}
```

**添加后更新 `parser.add_argument` 中的 choices**:
```python
parser.add_argument('-b', '--backend', default='google',
                    choices=BACKENDS.keys(),  # 自动包含新后端
                    help='后端选择 (默认: google)')
```

---

## 4. 模型配置

### 4.1 模型别名

| 别名 | 实际模型 | 默认命令 | 用途 |
|------|---------|---------|------|
| `pro3` | `gemini-3-pro-preview` | gchat | 复杂推理 |
| `flash3` | `gemini-3-flash-preview` | gflashchat | 快速响应 |
| `flash2` | `gemini-2.5-flash` | - | 保底模型 |
| `pro` | `gemini-2.5-pro` | - | 保底模型 |

### 4.2 模型降级机制

```
gemini-3-pro-preview   ───失败──→  gemini-2.5-pro
gemini-3-flash-preview ───失败──→  gemini-2.5-flash
```

修改降级映射 (编辑 `FALLBACK_MODELS`):
```python
FALLBACK_MODELS = {
    "gemini-3-pro-preview": "gemini-2.5-pro",
    "gemini-3-flash-preview": "gemini-2.5-flash",
    # 添加新的降级规则...
}
```

### 4.3 切换模型

```bash
# 命令行参数
gchat -m flash3          # 使用 flash3 模型
gflashchat               # 等同于 gchat -m flash3

# 交互模式
You> /model pro3
```

---

## 5. Function Calling

### 5.1 内置工具

| 工具名 | 函数名 | 说明 |
|--------|--------|------|
| `weather` | `get_weather` | 获取城市天气 |
| `search` | `web_search` | 网页搜索 |
| `calculator` | `calculate` | 数学计算 |
| `bash` | `run_bash` | 执行 bash 命令 |

### 5.2 使用工具

```bash
# 交互模式
gchat
You> /tools add weather     # 添加天气工具
You> /tools add bash        # 添加 bash 工具
You> 北京天气怎么样？        # 自动调用 get_weather
```

### 5.3 添加自定义工具

编辑 `bin/gchat` 中的 `BUILTIN_TOOLS`:

```python
BUILTIN_TOOLS = {
    "my_tool": {
        "name": "my_function",
        "description": "我的自定义工具",
        "parameters": {
            "type": "object",
            "properties": {
                "param1": {"type": "string", "description": "参数1"}
            },
            "required": ["param1"]
        }
    },
}
```

实现工具执行逻辑 (编辑 `execute_function`):

```python
def execute_function(name, args):
    if name == "my_function":
        param1 = args.get("param1")
        # 实现你的逻辑
        return {"result": f"处理了 {param1}"}
    # ... 其他工具
```

---

## 6. 命令参考

### 6.1 命令行参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `-m, --model` | `pro3` | 模型选择 |
| `-b, --backend` | `google` | 后端选择 |
| `-p, --prompt` | - | 单次提问 |
| `-c, --continue` | - | 继续上次会话 |
| `--list-models` | - | 列出可用模型 |

### 6.2 交互式命令

| 命令 | 说明 |
|------|------|
| `/help` | 显示帮助 |
| `/quit` | 退出并保存 |
| `/clear` | 清空对话历史 |
| `/status` | 显示当前状态 |
| `/model <name>` | 切换模型 |
| `/backend <name>` | 切换后端 |
| `/tools` | 工具管理 |
| `/history` | 显示对话历史 |
| `/save <file>` | 保存到文件 |
| `/load <file>` | 从文件加载 |

---

## 7. 技术实现

### 7.1 核心函数

```python
# OpenAI 格式工具调用 (google 后端)
def openai_tools_request(messages, model, tools, backend_config)

# Gemini 原生格式工具调用 (official 后端)
def official_api_request(messages, model, tools, api_key)

# 普通聊天请求
def chat_request(messages, model, backend_config)

# 带降级的聊天请求
def chat_request_with_fallback(messages, model, backend_config)
```

### 7.2 工具调用流程

```
用户输入
    ↓
检查 enabled_tools + supports_tools
    ↓
┌─────────────────┬─────────────────┐
│  google 后端    │  official 后端  │
│  OpenAI 格式    │  Gemini 格式    │
└─────────────────┴─────────────────┘
    ↓
解析 tool_calls
    ↓
execute_function()
    ↓
返回结果给模型
    ↓
最终回复
```

---

## 8. 配置文件示例

### 8.1 完整后端配置

```python
# bin/gchat
BACKENDS = {
    "google": {
        "url": "https://google-api.aihang365.com/v1/chat/completions",
        "name": "Google API (内部服务，支持Function Calling)",
        "supports_tools": True,
    },
    "local": {
        "url": "http://82.29.54.80:8100/v1/chat/completions",
        "name": "Gemini Reverse API (本地)",
        "supports_tools": False,
    },
    "nexus": {
        "url": "https://nexusai.aihang365.com/v1/chat/completions",
        "key": "GeminiReverseTest2025abcdefghijklmnopqrstuvwx",
        "name": "NexusAI",
        "supports_tools": False,
    },
    "official": {
        "url": "https://gemini-official.aihang365.com/v1beta/models/{model}:generateContent",
        "key": os.environ.get("GEMINI_API_KEY", ""),
        "name": "Google Official API (via US Proxy)",
        "supports_tools": True,
        "default_model": "gemini-2.5-flash-lite",
    },
}
```

### 8.2 环境变量

```bash
# 官方后端需要 API Key
export GEMINI_API_KEY="your-api-key-here"

# 添加到 ~/.zshrc 永久生效
echo 'export GEMINI_API_KEY="your-api-key"' >> ~/.zshrc
```

---

## 9. 使用场景

### 9.1 日常对话

```bash
gchat                    # 启动交互模式
gflashchat -p "2+2=?"    # 快速提问
```

### 9.2 编程助手

```bash
# 代码审查
gchat -p "审查这段代码: $(cat main.py)"

# 生成代码
gchat -p "写一个 Python 快速排序"
```

### 9.3 脚本集成

```bash
#!/bin/bash
# 获取 AI 建议并执行
suggestion=$(gchat -p "如何优化这个脚本: $(cat $0)")
echo "$suggestion"
```

---

## 10. 常见问题

### Q: 如何添加新的 API 后端？

A: 编辑 `bin/gchat` 中的 `BACKENDS` 字典：

```python
BACKENDS = {
    "myapi": {
        "url": "https://api.example.com/v1/chat/completions",
        "key": "sk-xxx",              # 可选
        "name": "My API",
        "supports_tools": False,      # 是否支持工具调用
    },
}
```

### Q: 如何修改默认模型？

A: 修改 `parser.add_argument` 中的 `default` 参数：

```python
parser.add_argument('-m', '--model', default='flash3', ...)  # 改为 flash3
```

### Q: Function Calling 不工作？

A: 检查：
1. 后端是否支持 (`supports_tools: True`)
2. 是否已添加工具 (`/tools add <name>`)
3. 使用 google 或 official 后端

---

## 11. 更新日志

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v4.0 | 2025-01-03 | 添加 Function Calling 支持，模型降级机制 |
| v3.0 | 2025-12-22 | 混合模式架构 |
| v2.0 | 2025-12-19 | 会话管理功能 |
| v1.0 | 2025-12-15 | 初始版本 |

---

**最后更新**: 2025-01-03
**维护者**: Mason (@mason0510)
