# CC Notify

Claude Code 快速通知工具 —— 当 AI 完成回复时，自动推送桌面通知。

> 本项目基于 [liujintai/claude-code-notify](https://github.com/liujintai/claude-code-notify) 改造，移除了对 Claude Haiku API 的依赖，实现了纯本地的极速响应模式。

![macOS](https://img.shields.io/badge/macOS-supported-brightgreen)
![Python 3](https://img.shields.io/badge/Python-3.8+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

## ✨ 特性

- ⚡ **极速响应**：<0.1 秒通知（毫秒级）
- 🎨 **自定义图标**：Claude 专属图标
- 🚀 **零依赖**：无需网络调用，100% 可靠
- 💡 **即装即用**：无需配置，开箱即用

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

### 方式一：一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/wanghuan9/cc-notify/main/install.sh | bash
```

### 方式二：克隆仓库安装

```bash
git clone https://github.com/wanghuan9/cc-notify.git
cd cc-notify
bash install.sh
```

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
2. `notify.py` 直接调用 `ClaudeNotify.app` 发送"任务已完成"通知
3. 通过自制的 `ClaudeNotify.app` 推送带 Claude 专属图标的 macOS 通知
4. **无需等待 API，无需文件读取，极速响应**

## 📁 文件结构

```
~/.claude/cc-notify/
├── notify.py               # 通知脚本
├── cc.jpg                  # 图标源文件
└── ClaudeNotify.app/       # Swift 通知工具
    └── Contents/
        ├── Info.plist
        ├── MacOS/ClaudeNotify
        └── Resources/AppIcon.icns
```

## 🔄 重新安装

如需重新安装或更新：

```bash
cd ~/.claude/cc-notify
bash install.sh
```

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
curl -fsSL https://raw.githubusercontent.com/wanghuan9/cc-notify/main/uninstall.sh | bash

# 方式二：手动卸载
rm -rf ~/.claude/cc-notify
# 然后手动编辑 ~/.claude/settings.json 删除 hooks 配置
```

## ❓ 常见问题

**Q: 安装后没有收到通知？**

A: 到 系统设置 → 通知 → ClaudeNotify 中确认通知权限已开启。

**Q: 支持 Linux 吗？**

A: notify.py 理论上支持 Linux（通过 `notify-send`），但安装脚本目前仅支持 macOS。

## 📜 许可证

MIT License
