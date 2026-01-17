# gchat-cli 项目须知

## 开源项目声明

**这是一个公开的开源项目**，代码托管在 GitHub: https://github.com/mason0510/gchat-cli

### 开发规范

1. **禁止提交敏感信息**：
   - API Keys、密码、私有 URL
   - 内部 IP 地址（如 `82.29.54.80`）
   - 私有域名（如 `*.aihang365.com`）

2. **配置通过环境变量**：
   - 所有敏感配置放在 `~/.gchat/.env`
   - 代码中使用 `os.environ.get()` 读取
   - `.env.example` 只包含模板，不含真实值

3. **Commit 规范**：
   - 不显示 AI 工具参与信息
   - 使用有意义的 commit message

## 项目定位

**Verbs for AI** - Skills 的下一代标准

- CLI 形式让 AI 更容易理解和调用
- 轻量级多模型网关
- 搭配 Claude Code 使用，节省 90% 成本
