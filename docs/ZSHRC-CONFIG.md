# GChat/Turing 环境变量配置

## 配置方式

在 `~/.zshrc` 中添加以下配置：

```bash
# ==================== GChat 配置 ====================
# GChat 使用的供应商 API
export GCHAT_BASE_URL="https://your-gchat-provider.com/v1/chat/completions"
export GCHAT_KEY="sk-your-gchat-key"

# ==================== Turing 配置 ====================
# Turing 使用的供应商 API（可与 GChat 不同）
export TURING_BASE_URL="https://your-turing-provider.com/v1/chat/completions"
export TURING_KEY="sk-your-turing-key"
```

## 应用配置

```bash
# 重新加载 zshrc
source ~/.zshrc

# 验证配置
gchat --list-models
turing --list-models
```

## 供应商切换

### 方法 1：修改 ~/.zshrc（永久）

```bash
# 编辑配置
vim ~/.zshrc

# 修改供应商 URL
export GCHAT_BASE_URL="https://new-provider.com/v1/chat/completions"
export GCHAT_KEY="sk-new-key"

# 应用
source ~/.zshrc
```

### 方法 2：临时切换（当前会话）

```bash
# 临时使用不同供应商
export GCHAT_BASE_URL="https://temp-provider.com/v1/chat/completions"
export GCHAT_KEY="sk-temp-key"

# 使用
gchat -p "测试"
```

## API 格式要求

供应商 API 必须支持 **OpenAI 兼容格式**：

**请求**：
```json
{
  "model": "gemini-2.5-flash",
  "messages": [
    {"role": "user", "content": "你好"}
  ]
}
```

**响应**：
```json
{
  "choices": [{
    "message": {
      "content": "你好！有什么我可以帮助你的吗？"
    }
  }]
}
```

**认证**：
```
Authorization: Bearer {GCHAT_KEY}
```

## 示例配置

### 示例 1：使用 NexusAI

```bash
export GCHAT_BASE_URL="https://nexusai.aihang365.com"
export GCHAT_KEY="sk-your-nexusai-key"
```

### 示例 2：使用本地 Reverse API

```bash
export GCHAT_BASE_URL="http://localhost:8100/v1/chat/completions"
export GCHAT_KEY=""  # 本地 API 可能不需要 key
```

### 示例 3：GChat 和 Turing 使用不同供应商

```bash
# GChat 使用供应商 A
export GCHAT_BASE_URL="https://provider-a.com/v1/chat/completions"
export GCHAT_KEY="sk-key-a"

# Turing 使用供应商 B
export TURING_BASE_URL="https://provider-b.com/v1/chat/completions"
export TURING_KEY="sk-key-b"
```

## 检查配置

```bash
# 查看当前配置
gchat --list-models

# 输出示例：
# 可用模型:
#   flash   -> gemini-3-flash-preview (最新 3.0 Flash) ⭐ 推荐
#   ...
#
# 当前配置 (GCHAT):
#   BASE_URL: https://your-provider.com/v1/chat/completions
#   KEY: 已设置
#
# 配置方式:
#   export GCHAT_BASE_URL='https://...'
#   export GCHAT_KEY='sk-...'
```

## 故障排查

### 问题 1：BASE_URL 未设置

```
BASE_URL: 未设置
```

**解决**：检查 `~/.zshrc` 中是否正确配置并执行 `source ~/.zshrc`。

### 问题 2：API 调用失败

```
[错误] Connection refused
```

**解决**：
1. 检查 URL 是否正确
2. 检查网络连接
3. 检查 API Key 是否有效

### 问题 3：返回格式错误

```
[错误] Invalid response format
```

**解决**：确认供应商 API 支持 OpenAI 兼容格式。
