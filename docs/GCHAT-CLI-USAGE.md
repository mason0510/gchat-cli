# gchat CLI 使用指南

**日期**: 2025-12-19
**版本**: v2.0.0

---

## 快速开始

### 单次提问 `-p` (适合CLI调用)

```bash
# 基本用法
gchat -p "你的问题"

# 指定模型
gchat -p "解释量子计算" -m pro

# 示例：在脚本中使用
ANSWER=$(gchat -p "1+1=?")
echo "答案: $ANSWER"
```

### 交互式对话

```bash
# 开启新对话
gchat

# 继续上次对话
gchat -c

# 使用指定模型
gchat -m pro
```

---

## 命令行参数完整列表

| 参数 | 说明 | 示例 |
|------|------|------|
| `-p, --prompt` | 单次提问（不进入交互模式） | `gchat -p "问题"` |
| `-c, --continue` | 继续上次会话 | `gchat -c` |
| `-m, --model` | 指定模型 | `gchat -m pro` |
| `-b, --backend` | 指定后端 | `gchat -b nexus` |
| `--list-models` | 列出可用模型 | `gchat --list-models` |
| `-h, --help` | 显示帮助 | `gchat --help` |

---

## CLI集成示例

### 在Shell脚本中使用

```bash
#!/bin/bash

# 获取AI建议
suggestion=$(gchat -p "给出3个提高效率的建议")
echo "$suggestion"

# 代码解释
code="def factorial(n): return 1 if n <= 1 else n * factorial(n-1)"
explanation=$(gchat -p "解释这段代码: $code")
echo "$explanation"

# 翻译
english_text="Hello, how are you?"
chinese=$(gchat -p "翻译成中文: $english_text")
echo "$chinese"
```

### 在Python中调用

```python
import subprocess
import json

def ask_gemini(question, model="flash"):
    """调用gchat获取AI回复"""
    result = subprocess.run(
        ['gchat', '-p', question, '-m', model],
        capture_output=True,
        text=True,
        timeout=30
    )
    return result.stdout.strip()

# 使用示例
answer = ask_gemini("什么是机器学习?")
print(answer)

# 使用Pro模型
detailed = ask_gemini("详细解释量子纠缠", model="pro")
print(detailed)
```

### 在Node.js中调用

```javascript
const { execSync } = require('child_process');

function askGemini(question, model = 'flash') {
  try {
    const result = execSync(
      `gchat -p "${question.replace(/"/g, '\\"')}" -m ${model}`,
      { encoding: 'utf8', timeout: 30000 }
    );
    return result.trim();
  } catch (error) {
    console.error('Error:', error.message);
    return null;
  }
}

// 使用示例
const answer = askGemini('什么是TypeScript?');
console.log(answer);
```

---

## 可用模型

| 模型别名 | 实际模型 | 适用场景 |
|---------|---------|---------|
| `flash` (默认) | gemini-3-flash-preview | 日常对话、快速响应 |
| `flash2` | gemini-2.5-flash | 旧版Flash |
| `pro` | gemini-2.5-pro | 复杂推理、代码生成 |
| `pro3` | gemini-3.0-pro | 最新Pro模型 |

---

## 后端配置

### 默认后端：NexusAI

```bash
# 使用NexusAI（默认）
gchat -p "test"

# 显式指定
gchat -p "test" -b nexus
```

### 本地后端（美国服务器）

```bash
# 使用本地google-reverse服务
gchat -p "test" -b local
```

**注意**: 本地后端仅支持curl调用，Python urllib/requests无法使用。

---

## 输出格式

### 纯文本输出（适合CLI）

```bash
$ gchat -p "1+1=?"
2
```

### 在脚本中捕获输出

```bash
# 捕获标准输出
result=$(gchat -p "hello")

# 捕获并处理错误
result=$(gchat -p "test" 2>&1)
if [[ $result == *"[API错误]"* ]]; then
    echo "API调用失败"
fi
```

---

## 错误处理

### 常见错误

| 错误类型 | 原因 | 解决方案 |
|---------|------|---------|
| `[API错误]: bad_response_status_code` | API token失效 | 检查BACKENDS配置中的key |
| `[连接错误]` | 网络问题 | 检查网络连接 |
| `[超时]` | 请求超过120秒 | 减少问题复杂度或检查网络 |
| `[JSON解析错误]` | API返回格式错误 | 检查API服务状态 |

### 错误处理示例

```bash
#!/bin/bash

result=$(gchat -p "test" 2>&1)

if [[ $result == *"[API错误]"* ]]; then
    echo "❌ API调用失败: $result"
    exit 1
elif [[ $result == *"[连接错误]"* ]]; then
    echo "❌ 网络连接失败"
    exit 1
else
    echo "✅ 成功: $result"
fi
```

---

## 性能优化

### 响应时间

| 模型 | 平均响应时间 |
|------|-------------|
| flash | 2-5秒 |
| flash2 | 2-5秒 |
| pro | 5-10秒 |
| pro3 | 5-10秒 |

### 批量调用优化

```bash
# ❌ 串行调用（慢）
for question in "q1" "q2" "q3"; do
    gchat -p "$question"
done

# ✅ 并行调用（快）
for question in "q1" "q2" "q3"; do
    gchat -p "$question" &
done
wait
```

---

## 高级用法

### 管道集成

```bash
# 从文件读取问题
cat questions.txt | xargs -I {} gchat -p "{}"

# 处理代码文件
cat main.py | gchat -p "解释这段代码"

# 生成报告
echo "总结今天的工作" | gchat -p "$(cat)" > daily_report.txt
```

### 交互式脚本

```bash
#!/bin/bash

echo "🤖 AI助手"
while true; do
    echo -n "You> "
    read question
    if [[ "$question" == "quit" ]]; then
        break
    fi
    echo -n "AI> "
    gchat -p "$question"
    echo
done
```

---

## 配置文件

### 后端配置位置

`/Users/houzi/bin/gchat` 第30-40行：

```python
BACKENDS = {
    "local": {
        "url": "http://82.29.54.80:8100/v1/chat/completions",
        "name": "Gemini Reverse API (本地)",
    },
    "nexus": {
        "url": "https://nexusai.aihang365.com/v1/chat/completions",
        "key": "YOUR_API_KEY_HERE",  # 需要替换为实际key
        "name": "NexusAI",
    },
}
```

### 自定义后端

要添加新后端，编辑 `/Users/houzi/bin/gchat`：

```python
BACKENDS = {
    # ... 现有后端 ...
    "custom": {
        "url": "https://your-api.com/v1/chat/completions",
        "key": "your-api-key",
        "name": "自定义后端",
    },
}
```

然后使用：

```bash
gchat -p "test" -b custom
```

---

## 故障排查

### 问题：API token失效

**现象**: `[API错误]: bad_response_status_code`

**解决**:
1. 检查 `/Users/houzi/bin/gchat` 中的BACKENDS配置
2. 确认API key是否有效
3. 测试API连接：`bash /tmp/test-nexusai.sh`

### 问题：命令not found

**现象**: `gchat: command not found`

**解决**:
```bash
# 检查gchat是否存在
ls -la /Users/houzi/bin/gchat

# 检查PATH
echo $PATH | grep "/Users/houzi/bin"

# 添加到PATH（如果需要）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 参考文档

- NexusAI API文档: `docs/zhongzhuan_API.md`
- gchat修复记录: `docs/GCHAT-FIX.md`
- 脚本位置: `/Users/houzi/bin/gchat`

---

**维护者**: Claude Code
**最后更新**: 2025-12-19
