#!/bin/bash
# gchat-cli 环境检查脚本
# TCD工作流标准组件

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║           gchat-cli 环境检查                           ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. 工作目录
echo "📁 工作目录:"
echo "   $(pwd)"
echo ""

# 2. Git状态
echo "🔧 Git状态:"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "   ✅ Git仓库已初始化"
    echo "   分支: $(git branch --show-current)"
    echo "   最近提交: $(git log -1 --oneline 2>/dev/null || echo '无提交')"
else
    echo "   ❌ 不是Git仓库"
fi
echo ""

# 3. Mock Server状态
echo "🖥️  Mock Server状态:"
if lsof -i :3456 > /dev/null 2>&1; then
    echo "   ✅ 运行中 (localhost:3456)"
    echo "   测试: curl http://localhost:3456/health"
else
    echo "   ⚠️  未启动"
    echo "   启动命令: cd mock-server && npm start"
fi
echo ""

# 4. 功能完成度
echo "📊 功能完成度:"
if [ -f "feature_list.json" ]; then
    completed=$(jq '.completed' feature_list.json)
    total=$(jq '.total_features' feature_list.json)
    in_progress=$(jq '.in_progress' feature_list.json)
    percentage=$((completed * 100 / total))

    # 进度条
    bar_length=20
    filled=$((percentage * bar_length / 100))
    empty=$((bar_length - filled))
    bar=$(printf '█%.0s' $(seq 1 $filled))$(printf '░%.0s' $(seq 1 $empty))

    echo "   $bar $percentage% ($completed/$total)"
    echo "   进行中: $in_progress"
else
    echo "   ❌ feature_list.json 不存在"
fi
echo ""

# 5. 待办任务 (前5个高优先级)
echo "📋 待办任务 (高优先级):"
if [ -f "feature_list.json" ]; then
    jq -r '.features[] | select(.passes == false and .priority == "high") |
        "   🔴 #\(.id): \(.description)"' feature_list.json | head -5

    medium_count=$(jq '[.features[] | select(.passes == false and .priority == "medium")] | length' feature_list.json)
    if [ "$medium_count" -gt 0 ]; then
        echo "   ⚠️  还有 $medium_count 个中优先级任务"
    fi
else
    echo "   ❌ feature_list.json 不存在"
fi
echo ""

# 6. 最近工作
echo "📝 最近工作:"
if [ -f "claude-progress.txt" ]; then
    echo "   查看: tail -30 claude-progress.txt"
    tail -10 claude-progress.txt | sed 's/^/   /'
else
    echo "   ❌ claude-progress.txt 不存在"
fi
echo ""

# 7. 基础测试
echo "🧪 基础功能测试:"
if [ -f "bin/gchat" ]; then
    echo "   ✅ gchat 可执行文件存在"
    if command -v gchat > /dev/null 2>&1; then
        echo "   ✅ gchat 已安装到PATH"
    else
        echo "   ⚠️  gchat 未安装 (运行 ./install.sh)"
    fi
else
    echo "   ❌ bin/gchat 不存在"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo ""
echo "✅ 环境检查完成"
echo ""
echo "下一步建议:"
echo "  1. 阅读 claude-progress.txt (最近工作)"
echo "  2. 运行 /tcd-deep (获取智能任务推荐)"
echo "  3. 或手动选择: jq '.features[] | select(.passes == false)' feature_list.json"
echo ""
