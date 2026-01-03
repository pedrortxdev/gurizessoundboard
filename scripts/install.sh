#!/bin/bash
# GurizesSoundboard - Install Script
# Installs the app and configures autostart

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="gurizes-soundboard"
BINARY_PATH="$PROJECT_DIR/src-tauri/target/release/$APP_NAME"
INSTALL_PATH="/usr/local/bin/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/gurizes-soundboard.desktop"
AUTOSTART_FILE="$HOME/.config/autostart/gurizes-soundboard.desktop"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          GurizesSoundboard - Instalação                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Binário não encontrado: $BINARY_PATH"
    echo "   Execute primeiro: npm run tauri build"
    exit 1
fi

echo "📦 Instalando binário em /usr/local/bin..."
sudo cp "$BINARY_PATH" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"
echo "   ✓ Binário instalado"

# Create directories
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.config/autostart"

# Create desktop entry
echo "📝 Criando entrada no menu..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GurizesSoundboard
Comment=Numpad Soundboard para Discord/Teams
Exec=$INSTALL_PATH
Icon=audio-card
Terminal=false
Categories=AudioVideo;Audio;
StartupWMClass=gurizes-soundboard
EOF
echo "   ✓ Entrada criada: $DESKTOP_FILE"

# Create autostart entry
echo "🚀 Configurando autostart..."
cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GurizesSoundboard
Comment=Numpad Soundboard para Discord/Teams
Exec=$INSTALL_PATH
Icon=audio-card
Terminal=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
EOF
echo "   ✓ Autostart configurado: $AUTOSTART_FILE"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              ✅ INSTALAÇÃO CONCLUÍDA!                        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  O app agora:                                                ║"
echo "║  • Está instalado em: /usr/local/bin/gurizes-soundboard      ║"
echo "║  • Aparece no menu de aplicativos                            ║"
echo "║  • Inicia automaticamente com o sistema                      ║"
echo "║                                                              ║"
echo "║  Para executar agora: gurizes-soundboard                     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
