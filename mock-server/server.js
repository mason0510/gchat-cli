/**
 * gchat Mock Server - 模拟 Function Calling 的 OpenAI 兼容 API
 *
 * 功能：
 * 1. 接收 chat/completions 请求
 * 2. 检测用户意图，返回 tool_calls
 * 3. 接收 tool 执行结果，返回最终回复
 */

const express = require('express');
const app = express();
const PORT = 3456;

app.use(express.json());

// 请求日志
app.use((req, res, next) => {
  console.log(`\n[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

/**
 * 检测用户消息中是否包含需要执行命令的意图
 */
function detectToolIntent(messages) {
  const lastUserMsg = messages.filter(m => m.role === 'user').pop();
  if (!lastUserMsg) return null;

  const content = lastUserMsg.content.toLowerCase();

  // 匹配模式：执行命令、运行命令、列出文件等
  const patterns = [
    { regex: /(?:执行|运行|跑一下)\s*[`"]?(.+?)[`"]?\s*(?:命令)?$/i, extract: 1 },
    { regex: /(?:列出|显示|查看)\s*(?:当前)?(?:目录)?(?:的)?(?:所有)?文件/, cmd: 'ls -la' },
    { regex: /(?:当前|显示)\s*(?:工作)?目录/, cmd: 'pwd' },
    { regex: /(?:查看|显示)\s*(?:系统)?时间/, cmd: 'date' },
    { regex: /(?:查看|显示)\s*磁盘\s*(?:空间|使用|占用)?/, cmd: 'df -h' },
    { regex: /(?:查看|显示)\s*内存\s*(?:使用|占用)?/, cmd: 'free -h || vm_stat' },
    { regex: /(?:运行|执行)\s*ls/, cmd: 'ls' },
    { regex: /(?:运行|执行)\s*pwd/, cmd: 'pwd' },
  ];

  for (const pattern of patterns) {
    const match = content.match(pattern.regex);
    if (match) {
      if (pattern.cmd) {
        return pattern.cmd;
      }
      if (pattern.extract && match[pattern.extract]) {
        return match[pattern.extract].trim();
      }
    }
  }

  return null;
}

/**
 * 检查消息中是否有 tool 执行结果
 */
function hasToolResult(messages) {
  return messages.some(m => m.role === 'tool');
}

/**
 * 获取最近的 tool 执行结果
 */
function getToolResults(messages) {
  return messages.filter(m => m.role === 'tool');
}

/**
 * 生成唯一 ID
 */
function generateId() {
  return 'call_' + Math.random().toString(36).substring(2, 15);
}

/**
 * POST /v1/chat/completions
 * OpenAI 兼容的聊天接口
 */
app.post('/v1/chat/completions', (req, res) => {
  const { model, messages, tools } = req.body;

  console.log('Model:', model);
  console.log('Messages count:', messages?.length);
  console.log('Tools defined:', tools ? 'Yes' : 'No');

  // 检查是否有 tool 执行结果
  if (hasToolResult(messages)) {
    // 有 tool 结果，生成最终回复
    const toolResults = getToolResults(messages);
    console.log('Processing tool results:', toolResults.length);

    const resultContent = toolResults.map(r => r.content).join('\n');

    const response = {
      id: 'chatcmpl-' + Date.now(),
      object: 'chat.completion',
      created: Math.floor(Date.now() / 1000),
      model: model || 'mock-model',
      choices: [{
        index: 0,
        message: {
          role: 'assistant',
          content: `命令执行完成，结果如下：\n\n\`\`\`\n${resultContent}\n\`\`\``
        },
        finish_reason: 'stop'
      }],
      usage: {
        prompt_tokens: 100,
        completion_tokens: 50,
        total_tokens: 150
      }
    };

    console.log('Response: Final text reply');
    return res.json(response);
  }

  // 没有 tool 结果，检查是否需要调用工具
  const command = detectToolIntent(messages);

  if (command && tools && tools.length > 0) {
    // 需要调用工具
    console.log('Detected command:', command);

    const response = {
      id: 'chatcmpl-' + Date.now(),
      object: 'chat.completion',
      created: Math.floor(Date.now() / 1000),
      model: model || 'mock-model',
      choices: [{
        index: 0,
        message: {
          role: 'assistant',
          content: '',
          tool_calls: [{
            id: generateId(),
            type: 'function',
            function: {
              name: 'run_bash',
              arguments: JSON.stringify({ command })
            }
          }]
        },
        finish_reason: 'tool_calls'
      }],
      usage: {
        prompt_tokens: 50,
        completion_tokens: 20,
        total_tokens: 70
      }
    };

    console.log('Response: tool_calls with command:', command);
    return res.json(response);
  }

  // 普通对话，返回文本
  const lastUserMsg = messages?.filter(m => m.role === 'user').pop()?.content || '';

  const response = {
    id: 'chatcmpl-' + Date.now(),
    object: 'chat.completion',
    created: Math.floor(Date.now() / 1000),
    model: model || 'mock-model',
    choices: [{
      index: 0,
      message: {
        role: 'assistant',
        content: `你好！我是 Mock Server。\n\n你说的是："${lastUserMsg}"\n\n我支持以下命令：\n- "列出当前目录文件"\n- "执行 ls 命令"\n- "显示当前目录"\n- "查看系统时间"`
      },
      finish_reason: 'stop'
    }],
    usage: {
      prompt_tokens: 30,
      completion_tokens: 40,
      total_tokens: 70
    }
  };

  console.log('Response: Normal text reply');
  return res.json(response);
});

/**
 * GET /v1/models
 * 列出可用模型
 */
app.get('/v1/models', (req, res) => {
  res.json({
    object: 'list',
    data: [
      { id: 'mock-model', object: 'model', created: Date.now(), owned_by: 'mock' },
      { id: 'mock-model-tools', object: 'model', created: Date.now(), owned_by: 'mock' }
    ]
  });
});

/**
 * 健康检查
 */
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════╗
║     gchat Mock Server - Function Calling 模拟器        ║
╠════════════════════════════════════════════════════════╣
║  端口: ${PORT}                                           ║
║  接口: POST /v1/chat/completions                       ║
║                                                        ║
║  支持的命令意图检测:                                   ║
║  - "列出当前目录文件" → ls -la                         ║
║  - "执行 xxx 命令" → xxx                               ║
║  - "显示当前目录" → pwd                                ║
║  - "查看系统时间" → date                               ║
╚════════════════════════════════════════════════════════╝

等待请求...
  `);
});
