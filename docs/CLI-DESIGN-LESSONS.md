# CLI 工具设计经验总结

> 基于 gchat-cli 项目的实战经验，适用于需要被 AI 理解和维护的命令行工具

## 核心原则

### 1. 自述文件是给 AI 看的

**问题**：人类看文档是为了"怎么用"，AI 看文档是为了"架构理解"。

**解决方案**：双层文档结构

```
README.md (纵览/索引)
├── 架构概览图
├── 文件索引 (文件名 + 一句话摘要)
└── 阅读指引

文件头部自述注释 (详细信息)
├── 架构角色
├── 输入/输出/依赖/配置
├── 入口命令
└── 相关脚本关联
```

AI 阅读顺序：`README.md` → 定位文件 → 读文件头部自述注释。

---

## 文档注释模板

### Python 脚本头部

```python
"""
================================================================================
架构角色: 主入口 / 多模型 CLI 网关
功能描述: 一句话概括核心功能
================================================================================
输入: CLI参数 / 用户交互输入 / 图片文件
输出: stdout (AI回复) / 会话历史文件
依赖: claude-code (子进程调用), python libs (wcwidth, sqlite3)
配置: ~/.gchat/.env (后端 API 地址和密钥)
================================================================================
入口:
  gchat                    # 交互式对话 (默认 flash3 模型)
  gchat -p "问题"          # 单次提问 (静默模式，不显示状态)
  gchat -c                 # 继续上次会话
  gchat -m pro             # 指定模型
实现:
  内部实现原理 (如: 调用 chat_request_with_fallback_stream)
相关:
  bin/turing               # 主程序副本 (功能相同)
  bin/gflashchat           # flash3 快捷方式
================================================================================
"""
```

### Bash 脚本头部

```bash
#!/bin/bash
# =============================================================================
# 架构角色: API 包装器 / 兼容层
# 功能描述: MiniMax API 的 Claude 兼容接口包装器
# =============================================================================
# 输入: CLI参数 / 环境变量 (API Key)
# 输出: stdout (claude 命令的输出)
# 依赖: claude (Claude Code CLI 命令)
# 配置: ~/.zshrc (MINIMAX_API_KEY, MINIMAX_BASE_URL, MINIMAX_ANTHROPIC_MODEL)
# =============================================================================
# 入口:
#   claudeminimax                    # 交互式 Claude Code
#   claudeminimax "问题"             # 单次提问
# 实现:
#   设置 ANTHROPIC_* 环境变量后 exec claude
# API: https://api.minimaxi.com/anthropic | 模型: MiniMax-M2.1
# 相关:
#   bin/claudeminimaxd   # Desktop 快捷
#   bin/claudeminimaxcd  # Code 快捷
# =============================================================================

export ANTHROPIC_BASE_URL="$MINIMAX_BASE_URL"
export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY"
export ANTHROPIC_MODEL="$MINIMAX_ANTHROPIC_MODEL"

claude "$@"
```

**关键点**：
- 使用 `===` 分隔符，视觉上易于定位
- 严格区分：输入/输出/依赖/配置
- 明确"相关脚本"，让 AI 理解整体关系
- 包含实现原理，不只是用法

---

## 环境变量管理

### ❌ 错误做法：硬编码

```bash
export ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="sk-cp-QnQIXimRR5MkTKeq0zQ1gdzJYpeaO1iK5bG69mb..."
export ANTHROPIC_MODEL="MiniMax-M2.1"
```

**问题**：
- 敏感信息暴露在代码中
- 无法快速切换配置
- 违反开源项目安全规范

### ✅ 正确做法：引用环境变量

**~/.zshrc** (用户配置层)：
```bash
export MINIMAX_API_KEY="sk-cp-QnQIXimRR5MkTKeq0zQ1gdzJYpeaO1iK5bG69mb..."
export MINIMAX_BASE_URL="https://api.minimaxi.com/anthropic"
export MINIMAX_ANTHROPIC_MODEL="MiniMax-M2.1"
```

**bin/claudeminimax** (工具层)：
```bash
export ANTHROPIC_BASE_URL="$MINIMAX_BASE_URL"
export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY"
export ANTHROPIC_MODEL="$MINIMAX_ANTHROPIC_MODEL"
```

**好处**：
- ✅ 开源项目不包含敏感信息
- ✅ 统一配置管理
- ✅ 快速切换环境（修改 ~/.zshrc 即可）

---

## 交互模式 vs 单次提问

### 经验法则

| 模式 | 状态反馈 | 原因 |
|------|---------|------|
| 交互模式 (`gchat`) | ✅ 显示 spinner + API 状态 | 用户不知道是否在处理 |
| 单次提问 (`gchat -p`) | ✅ 静默，直接输出结果 | 用户知道在等待 |

### 实现方式

```python
def interactive_mode(model, backend_name, continue_session=False):
    show_spinner = True  # 交互模式默认显示，让用户知道正在处理

    # ... 用户输入后 ...

    # verbose 模式下显示 API 调用信息
    if verbose:
        backend_display = backend_config.get('name', backend_name)
        print(colored(f"→ {model} · {backend_display} · Thinking...", Color.DIM))

    if use_stream:
        response = chat_request_with_fallback_stream(..., show_spinner=show_spinner)
```

```python
def single_prompt(prompt, model, backend_name, ...):
    # 单次提问：quiet=True, show_spinner=False
    response = chat_request_with_fallback(..., quiet=True, show_spinner=False)
```

### 为什么交互模式需要 spinner？

**场景**：用户输入问题后，按 Enter

**无 spinner**：
```
› 你好
[卡住 5 秒，没有任何反馈]
[用户以为卡死了，Ctrl+C]
```

**有 spinner**：
```
› 你好
→ gemini-2.5-flash · google · Thinking...
* Thinking··· (ctrl+c to interrupt · 3s)
[用户知道正在处理，耐心等待]
```

---

## README.md 纵览设计

### 目的

让 AI 在 30 秒内理解：
- 项目是什么
- 有哪些组件
- 组件之间的关系

### 模板

```markdown
## 架构概览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLI 网关层 (bin/)                              │
├─────────────────────────────────────────────────────────────────────────┤
│  gchat/turing          # 主入口 - 多模型 CLI 网关 (Python)               │
│  gflashchat           # 快捷入口 - 强制 flash3 模型 (Python)             │
│  claudeminimax*       # MiniMax API 包装器 - Claude 兼容接口 (Bash)      │
└─────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           API 后端层                                      │
├─────────────────────────────────────────────────────────────────────────┤
│  Gemini (Google)       # 主模型 - gemini-*-flash/preview                 │
│  GLM (智谱)            # 备用模型 - glm-4/glm-4-flash                     │
│  MiniMax              # Claude 兼容 - MiniMax-M2.1                       │
└─────────────────────────────────────────────────────────────────────────┘
```

### 文件索引

| 文件 | 自述摘要 |
|------|---------|
| `bin/gchat` | 主入口，多模型 CLI 网关，支持 Gemini/GLM/Official API |
| `bin/turing` | `gchat` 的副本，功能相同 |
| `bin/gflashchat` | 快捷入口，强制使用 flash3 模型 |
| `bin/claudeminimax` | API 包装器，MiniMax → Claude 兼容接口 |
| `bin/claudeminimaxd` | 快捷封装，Desktop 模式 (跳过权限) |
| `bin/claudeminimaxcd` | 快捷封装，Code 模式 (继续会话) |

> **阅读顺序**: 先读 README.md 定位文件，再读文件头部自述注释了解详情
```

**关键点**：
- ASCII 图展示层级关系
- 表格形式列出所有文件
- 一句话摘要，便于快速定位
- 明确阅读顺序

---

## 开源项目安全规范

### 禁止提交到 Git

```bash
# .gitignore
.env
*.key
*_SECRET*
*_API_KEY*
```

### 敏感配置管理

| 配置类型 | 存放位置 | 示例 |
|---------|---------|------|
| 用户私有配置 | `~/.zshrc` 或 `~/.gchat/.env` | API Keys |
| 公共模板 | `.env.example` | `API_KEY=your_key_here` |
| 代码中 | 仅引用环境变量 | `$MINIMAX_API_KEY` |

### Commit 规范

- ❌ 不要显示 AI 工具参与信息
- ✅ 使用有意义的 commit message
- ✅ 敏感信息绝不提交

---

## 快捷入口设计原则

### 何时需要快捷入口？

**场景**：主命令参数过长或常用

**示例**：
```bash
# 原命令
gchat -m flash3  # 每次都要输入

# 快捷入口
gflashchat      # 内部执行: gchat -m flash3
```

### 实现模板

**Python**:
```python
# gflashchat
args = [gchat_path, '-m', 'flash3'] + sys.argv[1:]
os.execv(sys.executable, [sys.executable] + args)
```

**Bash**:
```bash
# claudeminimaxcd
claudeminimax --dangerously-skip-permissions -c "$@"
```

**关键点**：
- 参数透传：`sys.argv[1:]` 或 `"$@"`
- 完全透明：用户感觉不到是包装器

---

## 同步到安装目录

### 开发 vs 安装

| 目录 | 用途 |
|------|------|
| `~/code/gchat-cli/bin/` | 开发目录 |
| `~/bin/` | 安装目录 (PATH 包含) |

### 同步脚本

```bash
# 修改开发目录后
cp bin/gchat bin/turing bin/gflashchat ~/bin/

# 验证
which gchat  # 应该输出: /Users/houzi/bin/gchat
```

**踩坑**：只改开发目录不同步，用户运行的还是旧版本。

---

## 总结

1. **文档分层**：README.md 索引 + 文件头自述注释
2. **环境变量**：统一管理 ~/.zshrc，代码只引用
3. **状态反馈**：交互模式显示 spinner，单次提问静默
4. **架构图**：ASCII 图 + 文件索引表
5. **快捷入口**：减少重复输入，保持透明
6. **安全第一**：敏感信息永不提交

核心理念：**代码是给人写的，文档是给 AI 看的**。
