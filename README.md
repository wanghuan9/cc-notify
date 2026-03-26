# CC Notify

Claude Code 快速通知工具 —— 当 AI 完成回复时，自动推送桌面通知。

![macOS](https://img.shields.io/badge/macOS-supported-brightgreen)
![Python 3](https://img.shields.io/badge/Python-3.8+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

## ✨ 特性

- ⚡ **极速响应**：<0.1 秒通知（毫秒级）
- 🎨 **自定义图标**：Claude 专属图标
- 🚀 **零依赖**：无需网络调用，100% 可靠
- 🔧 **两种模式**：快速模式（默认）和智能摘要模式

## 🎯 两种模式

### 快速模式（默认）

- ⚡ 响应速度：<0.1 秒
- 📝 通知内容："任务已完成"
- ✅ 无外部依赖
- 💡 **推荐**：适合大多数场景

### 智能摘要模式

- 🤖 响应速度：2-5 秒
- 📝 通知内容：AI 生成摘要（如"代码编写完成"、"Bug已修复"）
- 🔗 依赖 Claude Haiku API
- 💡 适合：需要个性化摘要时

## 📸 效果预览

当 Claude Code 完成任务后，你会收到通知：

![img_1.png](img_1.png)

![img.png](img.png)

## 💻 系统要求

- macOS（支持 Apple Silicon 和 Intel）
- Python 3.8+
- Swift 编译器（Xcode Command Line Tools）
- Claude Code CLI

## 🚀 安装

### 方式一：一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/liujintai/claude-code-notify/main/install.sh | bash
```

### 方式二：克隆仓库安装

```bash
git clone https://github.com/liujintai/claude-code-notify.git
cd claude-code-notify
bash install.sh
```

安装时会提示选择模式：
- **快速模式**（推荐，默认）
- **智能摘要模式**

## 📦 安装后

1. 新开一个 Claude Code 会话即可生效
2. 如未收到测试通知，请到 **系统设置 → 通知 → ClaudeNotify** 中开启通知权限

## ⚙️ 工作原理

```
Claude Code 回复结束
       ↓
  Stop Hook 触发
       ↓
  notify.py 执行
       ↓
  ClaudeNotify.app 推送通知
       ↓
  立即显示（<0.1 秒）
```

1. Claude Code 的 Stop Hook 在每次回复结束时触发 `notify.py`
2. `notify.py` 直接调用 `ClaudeNotify.app` 发送通知
3. 通过自制的 `ClaudeNotify.app` 推送带自定义图标的 macOS 通知
4. **无需等待 API，无需文件读取，极速响应**

## 📁 文件结构

```
~/.claude/claude-code-notify/
├── notify.py               # 通知脚本
├── cc.jpg                  # 图标源文件
└── ClaudeNotify.app/       # Swift 通知工具
    └── Contents/
        ├── Info.plist
        ├── MacOS/ClaudeNotify
        └── Resources/AppIcon.icns
```

## 🔄 切换模式

如需切换模式（快速 ↔ 智能摘要）：

```bash
cd ~/.claude/claude-code-notify
bash install.sh
```

选择不同的模式即可覆盖安装。

## 🎨 自定义图标

替换 `src/cc.jpg` 后重新运行安装脚本：

```bash
cd claude-code-notify
# 替换 src/cc.jpg 为你的图标
bash install.sh
```

## ❌ 卸载

```bash
# 方式一：使用卸载脚本
curl -fsSL https://raw.githubusercontent.com/liujintai/claude-code-notify/main/uninstall.sh | bash

# 方式二：手动卸载
rm -rf ~/.claude/claude-code-notify
# 然后手动编辑 ~/.claude/settings.json 删除 hooks 配置
```

## ❓ 常见问题

**Q: 安装后没有收到通知？**

A: 到 系统设置 → 通知 → ClaudeNotify 中确认通知权限已开启。

**Q: 通知延迟很大？**

A: 如果选择的是智能摘要模式，2-5 秒延迟是正常的。如需更快速度，重新安装并选择快速模式。

**Q: 支持 Linux 吗？**

A: notify.py 理论上支持 Linux（通过 `notify-send`），但安装脚本目前仅支持 macOS。

**Q: 如何检查当前模式？**

A: 查看 `~/.claude/claude-code-notify/.mode` 文件：
- `fast`：快速模式
- `original`：智能摘要模式

## 📊 性能数据

| 模式 | 响应速度 | 依赖 | 推荐度 |
|------|----------|------|--------|
| **快速模式** | <0.1 秒 | 无 | ⭐⭐⭐⭐⭐ |
| **智能摘要** | 2-5 秒 | Haiku API | ⭐⭐⭐ |

## 📜 许可证

MIT License
