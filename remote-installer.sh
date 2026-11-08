#!/usr/bin/env bash
set -euo pipefail

LOTD_URL="https://raw.githubusercontent.com/tedtasman/lotd/main/lotd-now"
BIN_DIR="$HOME/.local/bin"
TARGET="$BIN_DIR/lotd-now"
MOTD_DIR="/etc/update-motd.d"
MOTD_FILE="$MOTD_DIR/1000-lotd"

mkdir -p "$BIN_DIR"
curl -fsSL "$LOTD_URL" -o "$TARGET"
chmod 755 "$TARGET"
printf 'lotd-now installed at %s\n' "$TARGET"

# add ~/.local/bin to PATH if missing
if [[ ":$PATH:" != *":$BIN_DIR:"* ]] && ! grep -qF '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# lotd-now - add ~/.local/bin to PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
    printf '%s added to PATH in ~/.bashrc (applies to new shells)\n' "$BIN_DIR"
fi

if [[ ! -d $MOTD_DIR ]]; then
    echo "Failed to add lotd to Message of the Day, $MOTD_DIR missing" >&2
    exit 1
fi

echo "Authorize write to $MOTD_DIR:"
sudo install -m 755 "$TARGET" "$MOTD_FILE" && echo "Lottery of the Day added to Message of the Day"
