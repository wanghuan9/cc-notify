#!/usr/bin/env python3
"""
Claude Code Stop Hook - 快速通知（保留图标）
当 Claude Code 完成回复时，立即发送带自定义图标的桌面通知。
优化版本：移除 API 调用，使用固定文本，保留 ClaudeNotify.app 图标。
"""

import os
import subprocess
import sys


# ============================================================
# 配置
# ============================================================
NOTIFICATION_MESSAGE = "任务已完成"  # 固定通知文本

NOTIFY_APP_BUNDLE = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "ClaudeNotify.app",
)


# ============================================================
# 通知
# ============================================================
def send_notification(title: str, message: str):
    """发送带自定义图标的 macOS 桌面通知（优化版）"""
    message = message.replace("\n", " ")
    
    if sys.platform == "darwin" and os.path.isdir(NOTIFY_APP_BUNDLE):
        # 使用 ClaudeNotify.app 发送带自定义图标的通知
        # 关键优化：去掉 -W 参数，不等待 app 退出，大幅提升速度
        subprocess.run(
            ["open", "-n", NOTIFY_APP_BUNDLE,
             "--args", "-title", title, "-message", message],
            capture_output=True,
            timeout=3,  # 3秒超时足够（原来10秒）
        )
    elif sys.platform == "darwin":
        # 回退到系统通知（无自定义图标）
        msg = message.replace('"', '\\"')
        ttl = title.replace('"', '\\"')
        subprocess.run(
            ["osascript", "-e",
             f'display notification "{msg}" with title "{ttl}"'],
            capture_output=True,
            timeout=1,
        )
    else:
        # Linux 平台
        subprocess.run(
            ["notify-send", title, message],
            capture_output=True,
            timeout=1,
        )


# ============================================================
# 主入口
# ============================================================
def main():
    """快速发送带图标的通知"""
    send_notification("Claude Code", NOTIFICATION_MESSAGE)


if __name__ == "__main__":
    main()
