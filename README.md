# turing - Verbs for AI

**版本**: v3.0.0 | **日期**: 2026-01-17 | **作者**: Claude Code & Mason

> **Verbs** - Skills 的下一代标准。从名词到动词，从"我有什么能力"到"我要做什么"。
>
> CLI 形式让 AI 更容易理解和调用，一句命令完成复杂任务。

---

## 为什么叫 Verbs？

```
Skills = 名词 = 静态能力 = "我会什么"
Verbs  = 动词 = 主动行动 = "我要做什么"

┌─────────────────────────────────────────────────────────────────┐
│                    Don't skill it, verb it.                     │
└─────────────────────────────────────────────────────────────────┘
```

## 为什么用 turing？

```
┌─────────────────────────────────────────────────────────────────┐
│  Claude Code + GLM4.7 + turing = 99% Claude Code 官方模型功能   │
│                                                                 │
│  ✅ 成本节省 90%        ✅ 额外功能（图片生成、多模型切换）     │
│  ✅ CLI 形式易于 AI 调用  ✅ 无限对话（逆向 API）               │
└─────────────────────────────────────────────────────────────────┘
```

**核心价值**：
- **省钱**：用免费/低成本 API 替代官方高价模型
- **易集成**：CLI 命令比 API 调用更简洁，AI 助手可直接调用
- **多模型**：Gemini、GLM、官方 API 自由切换，自动降级
- **图片能力**：文生图、图生图、JSON 精准修图（Claude Code 没有的功能）

---

## 快速开始

### 安装

```bash
# 克隆并安装
git clone https://github.com/your-repo/gchat-cli.git
cp gchat-cli/bin/turing ~/bin/
cp gchat-cli/bin/gchat ~/bin/  # 可选：兼容旧命令
chmod +x ~/bin/turing ~/bin/turing

# 配置 API（复制模板并填写）
mkdir -p ~/.turing
cp gchat-cli/.env.example ~/.gchat/.env
# 编辑 ~/.gchat/.env 填入你的 API 配置

# 测试
turing --help
# 或者用 gchat --help（兼容）
```

### 基本使用

```bash
# 交互式对话
turing

# 单次提问（适合脚本/AI调用）
turing -p "什么是量子计算？"

# 继续上次对话
turing -c

# 指定模型
turing -p "复杂问题" -m pro

# 注：gchat 命令完全兼容，可以互换使用
```

---

## 核心功能

### 1. 对话模式

```bash
# 交互式对话
$ turing
You> 你好
AI> 你好！有什么可以帮你？

# 常用命令
You> /help          # 帮助
You> /clear         # 清空上下文
You> /history       # 查看对话历史
You> /sessions      # 列出所有会话
You> /stream        # 切换流式输出
You> /read file.py  # 读取文件让 AI 分析
You> /write out.md  # 保存 AI 回复到文件
You> /img photo.png # 发送图片
You> /paste         # 多行输入（Ctrl+S 发送）
You> /quit          # 退出并保存
```

### 2. 单次提问（CLI 集成）

```bash
# 基本提问
turing -p "1+1=?"

# JSON 输出（适合脚本解析）
turing -p "列出3种编程语言" --json

# 安静模式（仅输出结果）
turing -p "计算 100*200" -q

# 在 Claude Code 中调用
result=$(turing -p "总结这段代码的功能: $(cat main.py)")
```

### 3. AI 图片生成

```bash
# 文生图（免引号语法）
turing -d a cute orange cat sleeping

# 带引号也可以
turing --draw "一只橘猫在阳光下打盹"

# 图生图（垫图）
turing -d "改成水彩风格" -r ~/photo.jpg

# 选择图片模型
turing -d "高清风景" --image-model image-4k

# 查看图片历史
turing -H

# 搜索历史
turing -H cat
```

### 4. JSON 精准修图

```bash
# 步骤1：AI 分析图片生成 JSON 描述
turing -D ~/image.png
# 输出: {"background": "蓝天", "subject": "橘猫", "style": "写实", ...}

# 步骤2：修改 JSON（手动或让 AI 改）
turing -p "把 style 改成 水彩画风"

# 步骤3：用 JSON 重新生成
turing -E modified.json

# 可选：参考原图生成
turing -E modified.json -r original.png
```

### 5. 会话管理

```bash
# 继续上次对话
turing -c

# 查看所有会话
turing
You> /sessions

# 加载指定会话
You> /load gchat_history_20260117_120000.json

# 清空当前上下文
You> /clear
```

---

## 命令参考

### 命令行参数

| 参数 | 短参数 | 说明 | 示例 |
|------|--------|------|------|
| `--prompt` | `-p` | 单次提问 | `turing -p "问题"` |
| `--continue` | `-c` | 继续上次会话 | `turing -c` |
| `--model` | `-m` | 指定模型 | `turing -m pro` |
| `--backend` | `-b` | 指定后端 | `turing -b nexus` |
| `--json` | | JSON 格式输出 | `turing -p "问题" --json` |
| `--quiet` | `-q` | 安静模式 | `turing -p "问题" -q` |
| `--no-stream` | | 禁用流式输出 | `turing --no-stream` |
| `--list-models` | | 列出可用模型 | `turing --list-models` |
| `--draw` | `-d` | 文生图 | `turing -d a cute cat` |
| `--ref` | `-r` | 图生图参考图 | `turing -d "描述" -r img.jpg` |
| `--image-model` | | 图片模型 | `turing -d "描述" --image-model image-4k` |
| `--describe` | `-D` | 获取图片 JSON 描述 | `turing -D image.png` |
| `--edit-json` | `-E` | 用 JSON 生成图片 | `turing -E desc.json` |
| `--image-history` | `-H` | 查看图片历史 | `turing -H [关键词]` |
| `--history-limit` | | 历史数量限制 | `turing -H --history-limit 50` |

### 交互式命令

| 命令 | 说明 |
|------|------|
| `/help`, `/h` | 显示帮助 |
| `/quit`, `/q` | 退出并保存 |
| `/clear`, `/c` | 清空对话历史 |
| `/history` | 显示对话历史 |
| `/sessions` | 列出所有会话 |
| `/load <file>` | 加载会话文件 |
| `/save <file>` | 保存到指定文件 |
| `/model <name>` | 切换模型 |
| `/backend <name>` | 切换后端 |
| `/stream` | 切换流式输出 |
| `/status` | 显示当前状态 |
| `/read <file>` | 读取文件让 AI 分析 |
| `/write <file>` | 保存 AI 回复到文件 |
| `/img <path>` | 发送图片 |
| `/paste` | 多行输入模式 |
| `/mode [normal\|box]` | 切换输入模式 |

### 可用模型

| 别名 | 实际模型 | 适用场景 | 速度 |
|------|---------|---------|------|
| `flash3` (默认) | gemini-3-flash-preview | 日常对话 | 2-5秒 |
| `flash` | gemini-2.5-flash | 快速响应 | 2-5秒 |
| `pro` | gemini-2.5-pro | 复杂推理 | 5-10秒 |
| `pro3` | gemini-3.0-pro | 最新模型 | 5-10秒 |

---

## 配置

### 环境变量配置

```bash
# 创建配置目录
mkdir -p ~/.turing

# 复制模板
cp .env.example ~/.gchat/.env

# 编辑配置
vim ~/.gchat/.env
```

### 配置文件位置（按优先级）

1. `~/.gchat/.env` - 用户配置（推荐）
2. 项目目录 `.env`
3. 当前目录 `.env`

### 配置示例

```bash
# 主后端（OpenAI 兼容格式）
GOOGLE_API_URL=https://your-api-proxy.com/v1/chat/completions

# 备用后端
NEXUSAI_URL=https://your-api.com/v1/chat/completions
NEXUSAI_KEY=your_api_key

# 图片上传（可选，用于图片历史云存储）
R2_ACCESS_KEY_ID=your_key
R2_SECRET_ACCESS_KEY=your_secret
R2_BUCKET=turing
R2_ENDPOINT=https://xxx.r2.cloudflarestorage.com
R2_PUBLIC_URL=https://pub-xxx.r2.dev
```

---

## 使用场景

### 场景1：Claude Code 辅助

```bash
# 在 Claude Code 中调用 gchat 获取 Gemini 的回答
turing -p "用 Gemini 分析这个架构设计的优缺点: ..."

# 让 gchat 生成图片
turing -d "系统架构图，包含前端、后端、数据库"

# 对比不同模型的回答
turing -p "问题" -m flash3  # Gemini
turing -p "问题" -b official  # 官方 API
```

### 场景2：脚本集成

```bash
#!/bin/bash
# 自动生成 commit message
diff=$(git diff --staged)
message=$(turing -p "为这些改动生成简洁的 commit message: $diff" -q)
git commit -m "$message"
```

### 场景3：批量图片处理

```bash
# 批量生成产品图
for style in "简约" "科技感" "温馨"; do
  turing -d "手机产品图，${style}风格" --image-model image-2k
done

# 查看生成历史
turing -H
```

---

## 与 Claude Code 的配合

turing 设计为 Claude Code 的轻量级多模型网关：

```
┌──────────────────────────────────────────────────────────┐
│                      Claude Code                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  用户: "帮我用 Gemini 分析这个问题"                  │ │
│  │                                                      │ │
│  │  Claude Code 调用:                                   │ │
│  │  $ turing -p "分析问题..." -q                        │ │
│  │                                                      │ │
│  │  Claude Code 调用:                                   │ │
│  │  $ turing -d "生成示意图"                            │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

**优势**：
- CLI 命令比 API 调用更简洁
- AI 可以直接在 Bash 中调用
- 输出格式标准化，易于解析
- 支持 `--json` 和 `-q` 适配不同场景

---

## 文件结构

```
gchat-cli/
├── .env.example          # 配置模板
├── .gitignore
├── README.md
├── bin/
│   ├── gchat             # 主程序
│   └── gflashchat        # 快捷工具
├── docs/
│   └── GCHAT-CLI-USAGE.md
├── init.sh
└── install.sh
```

---

## 故障排查

### API 错误

```bash
# 检查配置
cat ~/.gchat/.env

# 测试连接
turing -p "test" -b local

# 切换后端
turing -p "test" -b nexus
```

### 命令找不到

```bash
# 检查安装
ls -la ~/bin/turing

# 添加到 PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 许可证

MIT License

---

## 作者

- **Claude Code** - AI 助手
- **Mason** - 项目维护者

---

**最后更新**: 2026-01-17 | **版本**: v3.0.0
