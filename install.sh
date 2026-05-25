#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Damagochi 설치 ==="

# Damagochi.app 설치
if [ -d "$SCRIPT_DIR/Damagochi.app" ]; then
    echo "→ Damagochi.app 설치 중..."
    rm -rf "/Applications/Damagochi.app"
    cp -r "$SCRIPT_DIR/Damagochi.app" "/Applications/Damagochi.app"
    xattr -cr "/Applications/Damagochi.app"
    echo "  완료: /Applications/Damagochi.app"
else
    echo "오류: Damagochi.app 파일을 찾을 수 없습니다."
    exit 1
fi

# damagochi CLI 설치
if [ -f "$SCRIPT_DIR/damagochi" ]; then
    echo "→ damagochi CLI 설치 중..."
    # /usr/local/bin 없는 Mac 대응
    sudo mkdir -p /usr/local/bin
    xattr -cr "$SCRIPT_DIR/damagochi"
    chmod +x "$SCRIPT_DIR/damagochi"
    sudo cp "$SCRIPT_DIR/damagochi" "/usr/local/bin/damagochi"
    echo "  완료: /usr/local/bin/damagochi"
else
    echo "오류: damagochi 파일을 찾을 수 없습니다."
    exit 1
fi

echo ""
echo "=== 설치 완료! ==="
echo ""
echo "실행 방법:"
echo "  open /Applications/Damagochi.app"
echo ""
echo "앱 실행 후 온보딩에서 Claude Code와 Codex 훅을 등록할 수 있습니다."
echo "Claude Code 또는 Codex를 사용할 때마다 펫이 성장합니다 :)"
