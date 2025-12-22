# gchat 命令 HTTP 502 错误修复

**问题日期**: 2025-12-19
**状态**: ✅ 已修复

---

## 问题描述

`gchat` 命令在交互模式下返回 HTTP 502 错误：

```
You> hi
AI>
[HTTP错误 502]:

You>
```

## 根本原因

`gchat` 默认使用 `local` 后端，指向美国服务器的 `google-reverse` 服务：

```python
"local": {
    "url": "http://82.29.54.80:8100/v1/chat/completions",
    "name": "Gemini Reverse API (本地)",
},
```

**问题分析**:
1. ✅ 服务本身在正常运行 (端口8100可访问，返回200 OK)
2. ✅ curl 可以正常调用API并获得响应
3. ❌ Python `urllib` 库调用时收到 502 Bad Gateway

**技术原因**: Python `urllib` 和 `google-reverse` 服务(基于uvicorn)之间的HTTP兼容性问题，可能与HTTP头或连接复用有关。

## 解决方案

### 方案一：使用 NexusAI 后端（推荐）✅

将 `gchat` 默认后端改为 NexusAI：

```python
# /Users/houzi/bin/gchat 第276行
parser.add_argument('-b', '--backend', default='nexus',  # 原: default='local'
                    choices=BACKENDS.keys(),
                    help='后端选择 (默认: nexus)')
```

**优势**:
- ✅ 稳定可靠
- ✅ 使用公网域名 (nexusai.aihang365.com)
- ✅ 有API Key认证
- ✅ Python urllib 完全兼容

### 方案二：手动指定后端

使用时指定 `--backend nexus`：

```bash
gchat --backend nexus
```

## 验证测试

```bash
# 测试单次问答
gchat -p "hi"

# 输出:
Hello! It's great to meet you. I'm Gemini, your AI thought partner...
```

## 后端配置

| 后端名称 | URL | 状态 | 说明 |
|---------|-----|------|------|
| **nexus** | https://nexusai.aihang365.com/v1/chat/completions | ✅ 推荐 | NexusAI 自研Gemini反向代理 |
| local | http://82.29.54.80:8100/v1/chat/completions | ⚠️ 仅curl可用 | 美国服务器 google-reverse |

## 技术细节

### NexusAI 后端配置

```python
"nexus": {
    "url": "https://nexusai.aihang365.com/v1/chat/completions",
    "key": "GeminiReverseTest2025abcdefghijklmnopqrstuvwx",
    "name": "NexusAI",
},
```

### 支持的模型

| 别名 | 实际模型 | 说明 |
|------|---------|------|
| flash (默认) | gemini-3-flash-preview | 最新 3.0 Flash ⭐ |
| flash3 | gemini-3-flash-preview | 同上 |
| flash2 | gemini-2.5-flash | 旧版 Flash |
| pro | gemini-2.5-pro | Pro 模型 |
| pro3 | gemini-3.0-pro | 3.0 Pro |

### 切换模型示例

```bash
# 使用 Pro 模型
gchat -m pro

# 使用 Gemini 3.0 Pro
gchat -m pro3
```

## 新增功能 (2025-12-19) ✨

### 1. 自动保存会话历史

**功能**: 退出 `gchat` 时自动保存会话历史到当前目录

**文件命名**: `gchat_history_YYYYMMDD_HHMMSS.json`

### 2. 继续上次对话 `-c` 参数 ⭐

**功能**: 自动加载最近的会话历史并继续对话

**使用方式**:
```bash
# 开启新对话
gchat

# 继续上次对话
gchat -c
```

**工作原理**:
1. 自动查找当前目录中的所有 `gchat_history_*.json` 文件
2. 加载最新的会话历史（按文件名时间戳排序）
3. 恢复对话上下文，可以继续之前的讨论

**保存内容**:
```json
{
  "model": "gemini-3-flash-preview",
  "messages": [
    {"role": "user", "content": "用户消息"},
    {"role": "assistant", "content": "AI回复"}
  ],
  "timestamp": "20251219_121944"
}
```

**触发时机**:
- ✅ 输入 `/quit` 退出时
- ✅ 按 `Ctrl+D` 退出时
- ❌ 空会话不保存（没有对话内容）

**恢复会话**:
```bash
gchat
> /load gchat_history_20251219_121944.json
对话已加载，共 2 条消息
```

## 使用场景示例

### 场景1：日常使用

```bash
# 第一天早上
$ gchat
You> 帮我写一个Python函数计算斐波那契数列
AI> 这是一个递归实现...
You> /quit
💾 会话已自动保存到: gchat_history_20251219_090000.json

# 下午继续讨论
$ gchat -c
📂 已加载会话: gchat_history_20251219_090000.json
   共 2 条消息 (1 轮对话)
You> 能优化一下性能吗？
AI> 可以使用动态规划...
```

### 场景2：多个独立任务

```bash
# 任务1：学习量子计算
$ cd ~/learning/quantum
$ gchat
You> 解释量子纠缠
...
You> /quit

# 任务2：工作项目
$ cd ~/work/project
$ gchat  # 新对话，不会混淆
You> 如何实现用户认证
...
```

### 场景3：手动管理历史

```bash
# 保存重要对话
You> /save important_discussion.json

# 稍后加载
$ gchat
You> /load important_discussion.json
```

## 相关命令

| 命令 | 说明 |
|------|------|
| `gchat` | 开启新对话 (默认使用 NexusAI) ⭐ |
| `gchat -c` | 继续上次对话 (自动加载最近历史) ⭐ |
| `gchat -p "问题"` | 单次问答 |
| `gchat -m pro` | 使用指定模型 |
| `gchat --list-models` | 列出可用模型和后端 |
| `/help` | 显示帮助 (交互模式内) |
| `/quit` | 退出并自动保存会话 |
| `/save <file>` | 手动保存到指定文件 |
| `/load <file>` | 加载指定历史会话 |
| `/history` | 查看当前会话历史 |
| `/backend nexus` | 切换后端 (交互模式内) |
| `/model pro` | 切换模型 (交互模式内) |

## 未来改进

可选的进一步优化：

1. **升级 HTTP 库**: 将 `urllib` 替换为 `requests` 或 `httpx`，更好的兼容性
2. **自动重试**: 添加 502 错误自动切换后端的逻辑
3. **健康检查**: 启动时检查后端可用性
4. **连接池**: 对于 local 后端使用持久连接

## 参考文档

- NexusAI API 文档: [docs/zhongzhuan_API.md](./zhongzhuan_API.md)
- gchat 脚本位置: `/Users/houzi/bin/gchat`

---

**修复者**: Claude Code
**修复日期**: 2025-12-19
