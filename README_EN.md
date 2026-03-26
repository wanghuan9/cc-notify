# CC Notify

Instant desktop notifications for Claude Code — get notified the moment AI completes its response.

![macOS](https://img.shields.io/badge/macOS-supported-brightgreen)
![Python 3](https://img.shields.io/badge/Python-3.8+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

## ✨ Features

- ⚡ **Lightning Fast**: <0.1s response time (millisecond-level)
- 🎨 **Custom Icon**: Claude-branded app icon
- 🚀 **Zero Dependencies**: No network calls, 100% reliable
- 🔧 **Dual Modes**: Fast mode (default) and Smart Summary mode

## 🎯 Two Modes

### Fast Mode (Default)

- ⚡ Response: <0.1 second
- 📝 Content: "Task Completed" (fixed message)
- ✅ Dependencies: None
- 💡 **Recommended**: Best for most use cases

### Smart Summary Mode

- 🤖 Response: 2-5 seconds
- 📝 Content: AI-generated summary (e.g., "Code Completed", "Bug Fixed")
- 🔗 Dependencies: Claude Haiku API
- 💡 Best for: When you need personalized summaries

## 📸 Preview

When Claude Code completes a task, you'll receive a notification:

![img_1.png](img_1.png)

![img.png](img.png)

## 💻 Requirements

- macOS (Apple Silicon and Intel supported)
- Python 3.8+
- Swift Compiler (Xcode Command Line Tools)
- Claude Code CLI

## 🚀 Installation

### Method 1: One-Click Install

```bash
curl -fsSL https://raw.githubusercontent.com/liujintai/cc-notify/main/install.sh | bash
```

### Method 2: Clone Repository

```bash
git clone https://github.com/liujintai/cc-notify.git
cd cc-notify
bash install.sh
```

During installation, you'll be prompted to choose a mode:
- **Fast Mode** (recommended, default)
- **Smart Summary Mode**

## 📦 After Installation

1. Start a new Claude Code session
2. If you don't see the test notification, go to **System Settings → Notifications → ClaudeNotify** and enable notifications

## ⚙️ How It Works

```
Claude Code finishes response
       ↓
  Stop Hook triggered
       ↓
  notify.py executes
       ↓
  ClaudeNotify.app sends notification
       ↓
  Instant display (<0.1s)
```

1. Claude Code's Stop Hook triggers `notify.py` when each response completes
2. `notify.py` directly calls `ClaudeNotify.app` to send notification
3. Sends macOS notification with custom icon via self-built `ClaudeNotify.app`
4. **No API waiting, no file reading, lightning fast**

## 📁 File Structure

```
~/.claude/cc-notify/
├── notify.py               # Notification script
├── cc.jpg                  # Icon source file
└── ClaudeNotify.app/       # Swift notification tool
    └── Contents/
        ├── Info.plist
        ├── MacOS/ClaudeNotify
        └── Resources/AppIcon.icns
```

## 🔄 Switch Modes

To switch modes (Fast ↔ Smart Summary):

```bash
cd ~/.claude/cc-notify
bash install.sh
```

Choose a different mode to overwrite the current installation.

## 🎨 Custom Icon

Replace `src/cc.jpg` and re-run the installation script:

```bash
cd cc-notify
# Replace src/cc.jpg with your icon
bash install.sh
```

## ❌ Uninstall

```bash
# Method 1: Use uninstall script
curl -fsSL https://raw.githubusercontent.com/liujintai/cc-notify/main/uninstall.sh | bash

# Method 2: Manual uninstall
rm -rf ~/.claude/cc-notify
# Then manually edit ~/.claude/settings.json to remove hooks config
```

## ❓ FAQ

**Q: No notification after installation?**

A: Go to System Settings → Notifications → ClaudeNotify and confirm notification permissions are enabled.

**Q: High notification latency?**

A: If you selected Smart Summary mode, 2-5s latency is normal. For faster speed, reinstall and choose Fast mode.

**Q: Does it support Linux?**

A: notify.py theoretically supports Linux (via `notify-send`), but the installation script currently only supports macOS.

**Q: How to check current mode?**

A: Check `~/.claude/cc-notify/.mode` file:
- `fast`: Fast mode
- `original`: Smart summary mode

## 📊 Performance

| Mode | Response Time | Dependencies | Rating |
|------|---------------|--------------|--------|
| **Fast Mode** | <0.1s | None | ⭐⭐⭐⭐⭐ |
| **Smart Summary** | 2-5s | Haiku API | ⭐⭐⭐ |

## 🔧 Configuration

### Debug Mode

Edit hooks command in `~/.claude/settings.json`, add `NOTIFY_DEBUG=1`:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "NOTIFY_DEBUG=1 python3 $HOME/.claude/cc-notify/notify.py"
      }]
    }]
  }
}
```

Debug logs are written to `~/.claude/notify_debug.log`.

### Custom Icon

Replace `~/.claude/cc-notify/cc.jpg` and re-run install script.

### API Configuration

For Smart Summary mode, notify script uses environment variables from Claude Code session:

- `ANTHROPIC_BASE_URL` — API base URL (default `https://api.anthropic.com`)
- `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` — API key

No additional configuration needed, script automatically inherits Claude Code's environment.

## 🛠️ Development

### Project Structure

```
cc-notify/
├── README.md              # Chinese documentation
├── README_EN.md           # English documentation (this file)
├── install.sh             # Installation script
├── uninstall.sh           # Uninstallation script
├── img.png                # Screenshot 1
├── img_1.png              # Screenshot 2
└── src/
    ├── ClaudeNotify.app/  # Notification app
    ├── ClaudeNotify.swift # Swift source code
    ├── cc.jpg             # Claude icon
    └── notify.py          # Notification script
```

### Building ClaudeNotify.app

```bash
cd src
swiftc ClaudeNotify.swift \
    -o ClaudeNotify.app/Contents/MacOS/ClaudeNotify \
    -framework Cocoa \
    -framework UserNotifications
```

## 📜 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions:
- Open an issue on GitHub
- Check the FAQ section above

---

**Made with ❤️ for Claude Code users**
