# GChat v5.0 规划

> 定位: **Claude Code 的轻量多模型网关**

## 核心定位

```
gchat 是什么：
├── Claude Code 的第三方模型接口
│   └── 一个命令接入 Gemini/GPT/本地模型
├── 程序员日常工具
│   └── 聊天、读写文件、图片处理、格式转换
├── 轻量级
│   └── 单文件 <2000行，不装 gemini-cli/codex 等重型工具
└── 单人可维护

gchat 不是什么：
├── ❌ 完整 AI Agent (不做 MCP、沙箱、插件)
├── ❌ Claude Code 的替代品
└── ❌ 企业级产品
```

## 为什么需要 gchat

```
问：为什么不直接用 gemini-cli / codex？
答：太重了，50-100MB，功能冗余

问：为什么不让 Claude Code 直接调 API？
答：gchat 提供统一接口，一个命令切换多模型

┌─────────────────────────────────────┐
│         Claude Code                  │
│      (绑定 Claude 模型)              │
└─────────────────────────────────────┘
         │ 需要其他模型时
         ▼
┌─────────────────────────────────────┐
│              gchat                   │
│  --backend google  → Gemini         │
│  --backend openai  → GPT            │
│  --backend local   → 本地模型        │
└─────────────────────────────────────┘
```

## 使用场景

```bash
# 1. 方案校对 (双AI交叉验证)
gchat -p "请校对以下方案的逻辑和可行性：[方案摘要]"

# 2. 选择题委托
gchat -p "选项1/2/3，回答编号+理由"

# 3. 快速查询
gchat -p "Python 怎么读取 TOML 文件"

# 4. 脚本集成
result=$(gchat -p "总结这段日志的错误原因" < error.log)
```

---

## v5.0 功能规划

### 借鉴 Claude Code (简化版)

| 特性 | Claude Code | gchat v5.0 |
|------|-------------|------------|
| 命令设计 | `/help` `/clear` `/img` | 同样 `/` 前缀 |
| 输入模式 | normal / box 切换 | ✅ 已有 |
| 自动保存 | 会话自动持久化 | ✅ 已有 |
| **实时中断** | Ctrl+C 保存上下文 | 新增 |
| **上下文压缩** | 超长对话自动摘要 | 新增 |
| **流式输出** | 实时显示响应 | 新增 (P0) |

### 完整命令清单

```bash
# === 基础 ===
/help                   # 显示帮助
/clear                  # 清空当前对话
/history                # 查看对话历史
/sessions               # 列出所有会话
/quit 或 /q             # 退出 (自动保存)

# === 文件操作 ===
/read <file>            # 读取文件让AI分析
/write <file>           # 保存AI回复到文件
/convert <file> <fmt>   # 格式转换 (png→jpg, pdf→md)

# === 图片 ===
/img <file>             # 分析图片
/gen <prompt>           # 生成图片 (Gemini 3)
/edit <file> <prompt>   # 编辑图片 (Gemini 3)

# === 模式 ===
/mode box               # 切换到多行输入框
/mode normal            # 切换到普通模式

# === 后端 ===
/backend google         # 切换到 Gemini
/backend openai         # 切换到 GPT
/backend local          # 切换到本地模型
```

### 核心功能状态

| 功能 | 当前 | v5.0 |
|------|------|------|
| 聊天 | ✅ | 保持 |
| 图片分析 | ✅ | 保持 |
| 自动保存 | ✅ | 保持 |
| 输入模式切换 | ✅ | 保持 |
| **流式输出** | ❌ | P0 新增 |
| **实时中断** | ❌ | P0 新增 |
| **上下文压缩** | ❌ | P1 新增 |
| **/read** | ❌ | P0 新增 |
| **/write** | ❌ | P0 新增 |
| **/gen (生图)** | ❌ | P1 新增 |
| **/edit (编辑图)** | ❌ | P1 新增 |
| **/convert** | ❌ | P1 新增 |

### 不做

| 特性 | 原因 |
|------|------|
| MCP 协议 | 复杂度高，收益低 |
| 沙箱隔离 | 信任用户环境 |
| 插件系统 | 过度设计 |
| Agent 逻辑 | 那是 Claude Code 的事 |

---

## 代码目标

```
v4.0: 1271 行
v5.0: < 2000 行
```

保持：
- 单文件部署
- 零配置可用
- 依赖最小化 (prompt_toolkit, wcwidth, Pillow)

---

## 实现优先级

```
P0 (v5.0 必做):
├── 流式输出
├── 实时中断 (Ctrl+C 保存上下文)
├── /read <file>
├── /write <file>
├── /clear, /history, /sessions
└── --json 输出

P1 (v5.1):
├── 上下文压缩 (超长对话自动摘要)
├── /gen <prompt> 生成图片
├── /edit <file> <prompt> 编辑图片
└── /convert <file> <fmt> 格式转换

P2 (按需):
├── /backend 动态切换
└── 更多后端支持
```

---

## 技术实现要点

### 流式输出
```python
# SSE 流式读取
for line in response.iter_lines():
    if line.startswith(b'data: '):
        chunk = json.loads(line[6:])
        print(chunk['content'], end='', flush=True)
```

### 实时中断
```python
import signal

def handle_interrupt(sig, frame):
    auto_save_history(messages, model)
    print("\n💾 已保存，按 Enter 继续或 /q 退出")

signal.signal(signal.SIGINT, handle_interrupt)
```

### 上下文压缩
```python
def compress_context(messages):
    if count_tokens(messages) > THRESHOLD:
        summary = gchat_request("总结以上对话要点", messages)
        return [{"role": "system", "content": f"之前对话摘要: {summary}"}]
    return messages
```

---

## 依赖清单

```
必需:
├── prompt_toolkit  # 输入框
├── wcwidth         # 字符宽度
└── Pillow          # 图片处理

可选:
└── sseclient       # 流式输出 (或用 requests 原生)
```

---

不设时间线，按需迭代。
