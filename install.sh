#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Code Notify - 一键安装脚本
# 快速模式：固定文本，毫秒级响应，无 API 依赖
# 基于 https://github.com/liujintai/claude-code-notify 改造
# ============================================================

VERSION="2.0.0"
INSTALL_DIR="$HOME/.claude/cc-notify"
SETTINGS_FILE="$HOME/.claude/settings.json"
REPO_URL="https://raw.githubusercontent.com/wanghuan9/cc-notify/main"
VERSION_FILE="$INSTALL_DIR/.version"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
# 0. 检测已安装版本
# ============================================================
if [[ -f "$VERSION_FILE" ]]; then
    INSTALLED_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "unknown")

    echo ""
    echo -e "${GREEN}检测到已安装 v${INSTALLED_VERSION}${NC}"
    echo ""
    echo "  安装位置: $INSTALL_DIR/"
    echo "  配置文件: $SETTINGS_FILE"
    echo ""
    read -rp "是否重新安装？[y/N] " choice
    case "$choice" in
        y|Y) ;;
        *)   echo "已取消。"; exit 0 ;;
    esac
elif [[ -f "$INSTALL_DIR/notify.py" ]]; then
    # 旧版安装（没有版本文件）
    echo ""
    echo -e "${YELLOW}检测到已有安装（版本未知）${NC}"
    echo ""
    read -rp "是否覆盖安装？[Y/n] " choice
    case "$choice" in
        n|N) echo "已取消。"; exit 0 ;;
    esac
fi

# ============================================================
# 1. 环境检查
# ============================================================
info "检查运行环境..."

if [[ "$(uname)" != "Darwin" ]]; then
    error "仅支持 macOS 系统"
fi

if ! command -v swift &>/dev/null; then
    error "未找到 Swift 编译器，请先安装 Xcode Command Line Tools: xcode-select --install"
fi

if ! command -v python3 &>/dev/null; then
    error "未找到 python3"
fi

if ! command -v iconutil &>/dev/null; then
    error "未找到 iconutil（macOS 系统自带，不应缺失）"
fi

ok "环境检查通过 (Swift $(swift --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'))"

# ============================================================
# 2. 准备工作目录
# ============================================================
info "准备安装目录..."

WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

mkdir -p "$INSTALL_DIR"

# 判断是本地安装还是远程安装
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd 2>/dev/null || echo "")"
if [[ -f "$SCRIPT_DIR/src/ClaudeNotify.swift" ]]; then
    # 本地安装（从 clone 的仓库）
    info "检测到本地源码，使用本地文件..."
    SRC_DIR="$SCRIPT_DIR/src"
else
    # 远程安装（curl | bash）
    info "下载源码..."
    SRC_DIR="$WORK_DIR/src"
    mkdir -p "$SRC_DIR"
    curl -fsSL "$REPO_URL/src/ClaudeNotify.swift" -o "$SRC_DIR/ClaudeNotify.swift"
    curl -fsSL "$REPO_URL/src/cc.jpg" -o "$SRC_DIR/cc.jpg"
    curl -fsSL "$REPO_URL/src/notify.py" -o "$SRC_DIR/notify.py"

    ok "源码下载完成"
fi

# ============================================================
# 3. 转换图标 (jpg → icns)
# ============================================================
info "转换应用图标..."

ICONSET_DIR="$WORK_DIR/cc.iconset"
mkdir -p "$ICONSET_DIR"

for size in 16 32 64 128 256 512 1024; do
    sips -z $size $size "$SRC_DIR/cc.jpg" --out "$ICONSET_DIR/tmp_${size}.png" -s format png &>/dev/null
done

# 按 macOS iconset 命名规范重命名
cp "$ICONSET_DIR/tmp_16.png"   "$ICONSET_DIR/icon_16x16.png"
cp "$ICONSET_DIR/tmp_32.png"   "$ICONSET_DIR/icon_16x16@2x.png"
cp "$ICONSET_DIR/tmp_32.png"   "$ICONSET_DIR/icon_32x32.png"
cp "$ICONSET_DIR/tmp_64.png"   "$ICONSET_DIR/icon_32x32@2x.png"
cp "$ICONSET_DIR/tmp_128.png"  "$ICONSET_DIR/icon_128x128.png"
cp "$ICONSET_DIR/tmp_256.png"  "$ICONSET_DIR/icon_128x128@2x.png"
cp "$ICONSET_DIR/tmp_256.png"  "$ICONSET_DIR/icon_256x256.png"
cp "$ICONSET_DIR/tmp_512.png"  "$ICONSET_DIR/icon_256x256@2x.png"
cp "$ICONSET_DIR/tmp_512.png"  "$ICONSET_DIR/icon_512x512.png"
cp "$ICONSET_DIR/tmp_1024.png" "$ICONSET_DIR/icon_512x512@2x.png"
rm -f "$ICONSET_DIR"/tmp_*.png

iconutil -c icns "$ICONSET_DIR" -o "$WORK_DIR/AppIcon.icns"
ok "图标转换完成"

# ============================================================
# 4. 编译 Swift 通知工具
# ============================================================
info "编译 ClaudeNotify.app..."

APP_DIR="$INSTALL_DIR/ClaudeNotify.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# 编译（自动适配当前 CPU 架构）
swiftc "$SRC_DIR/ClaudeNotify.swift" \
    -o "$APP_DIR/Contents/MacOS/ClaudeNotify" \
    -framework Cocoa \
    -framework UserNotifications \
    2>&1

# Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.claude.notify</string>
    <key>CFBundleName</key>
    <string>ClaudeNotify</string>
    <key>CFBundleExecutable</key>
    <string>ClaudeNotify</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSUserNotificationAlertStyle</key>
    <string>banner</string>
</dict>
</plist>
PLIST

# 图标
cp "$WORK_DIR/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"

# 签名
codesign --force --sign - "$APP_DIR" 2>/dev/null

# 注册到 Launch Services
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [[ -x "$LSREGISTER" ]]; then
    "$LSREGISTER" -f "$APP_DIR"
    ok "已注册到系统 Launch Services"
else
    warn "未找到 lsregister，请手动打开一次 ClaudeNotify.app"
fi

ok "编译完成并已签名"

# ============================================================
# 5. 安装 notify.py 和图标
# ============================================================
info "安装通知脚本（快速模式）..."

# 使用快速模式的 notify.py
if [[ -f "$SCRIPT_DIR/src/notify.py" ]]; then
    cp "$SCRIPT_DIR/src/notify.py" "$INSTALL_DIR/notify.py"
else
    # 远程安装时，已在前面下载
    cp "$SRC_DIR/notify.py" "$INSTALL_DIR/notify.py"
fi

cp "$SRC_DIR/cc.jpg" "$INSTALL_DIR/cc.jpg"
chmod +x "$INSTALL_DIR/notify.py"

# 写入版本文件
echo "$VERSION" > "$VERSION_FILE"

ok "文件安装完成 → $INSTALL_DIR/"

# ============================================================
# 6. 配置 Claude Code Hooks
# ============================================================
info "配置 Claude Code hooks..."

HOOK_CMD='python3 $HOME/.claude/cc-notify/notify.py'

# 检查 settings.json 中是否已有 notify.py 相关的 hook
_hook_exists() {
    [[ -f "$SETTINGS_FILE" ]] && python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    cfg = json.load(f)
for h in cfg.get('hooks', {}).get('Stop', []):
    for hh in h.get('hooks', []):
        if 'notify.py' in hh.get('command', ''):
            sys.exit(0)
sys.exit(1)
" 2>/dev/null
}

if _hook_exists; then
    ok "hooks 已存在，跳过配置"
else
    if [[ -f "$SETTINGS_FILE" ]]; then
        # 合并 hooks 到已有配置
        python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    cfg = json.load(f)
hooks = cfg.setdefault('hooks', {})
stop = hooks.setdefault('Stop', [])
stop.append({
    'hooks': [{
        'type': 'command',
        'command': '$HOOK_CMD'
    }]
})
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
"
        ok "hooks 已写入 $SETTINGS_FILE"
    else
        # 创建新的 settings.json
        python3 -c "
import json
cfg = {
    'hooks': {
        'Stop': [{
            'hooks': [{
                'type': 'command',
                'command': '$HOOK_CMD'
            }]
        }]
    }
}
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
"
        ok "已创建 $SETTINGS_FILE"
    fi
fi

# ============================================================
# 7. 发送测试通知
# ============================================================
info "发送测试通知..."

TEST_MESSAGE="快速模式已启用！通知将在 <0.1 秒内显示。"

open -n "$APP_DIR" --args \
    -title "Claude Code Notify" \
    -message "$TEST_MESSAGE" &

# ============================================================
# 完成
# ============================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Claude Code Notify v${VERSION} 安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  安装位置: $INSTALL_DIR/"
echo "  配置文件: $SETTINGS_FILE"
echo ""
echo -e "  安装模式: ${GREEN}快速模式（极速响应）${NC}"
echo "  响应速度: <0.1 秒"
echo "  通知内容: \"任务已完成\""
echo ""
echo "  新开一个 Claude Code 会话即可生效。"
echo ""
echo -e "  ${CYAN}重新安装：${NC}"
echo "  cd ~/.claude/cc-notify && bash install.sh"
echo ""
echo -e "  ${YELLOW}提示: 如果没看到测试通知，请到${NC}"
echo -e "  ${YELLOW}系统设置 → 通知 → ClaudeNotify 中开启通知权限${NC}"
echo ""
