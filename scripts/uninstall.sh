#!/bin/bash
# GurizesSoundboard - Uninstall Script

INSTALL_PATH="/usr/local/bin/gurizes-soundboard"
DESKTOP_FILE="$HOME/.local/share/applications/gurizes-soundboard.desktop"
AUTOSTART_FILE="$HOME/.config/autostart/gurizes-soundboard.desktop"

echo "🗑️ Removendo GurizesSoundboard..."

[ -f "$INSTALL_PATH" ] && sudo rm "$INSTALL_PATH" && echo "   ✓ Binário removido"
[ -f "$DESKTOP_FILE" ] && rm "$DESKTOP_FILE" && echo "   ✓ Entrada do menu removida"
[ -f "$AUTOSTART_FILE" ] && rm "$AUTOSTART_FILE" && echo "   ✓ Autostart removido"

echo ""
echo "✅ GurizesSoundboard desinstalado!"
