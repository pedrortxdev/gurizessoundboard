#!/bin/bash
# GurizesSoundboard - Startup Script
# Inicia o soundboard e configura adb reverse automaticamente

SOUNDBOARD_BIN="/usr/local/bin/gurizes-soundboard"

echo "🎛️ Iniciando GurizesSoundboard..."

# Verifica se o binário existe
if [ ! -f "$SOUNDBOARD_BIN" ]; then
    echo "❌ Binário não encontrado: $SOUNDBOARD_BIN"
    echo "   Execute: sudo ln -sf /home/daniel/Documentos/soundboard/src-tauri/target/release/gurizes-soundboard /usr/local/bin/gurizes-soundboard"
    exit 1
fi

# Inicia o soundboard em background
$SOUNDBOARD_BIN &
SOUNDBOARD_PID=$!
echo "✅ Soundboard iniciado (PID: $SOUNDBOARD_PID)"

# Aguarda o servidor TCP iniciar
sleep 2

# Configura adb reverse (se celular estiver conectado)
setup_adb() {
    if command -v adb &> /dev/null; then
        # Verifica se há dispositivo conectado
        DEVICE=$(adb devices 2>/dev/null | grep -v "List\|^$" | head -1)
        if [ -n "$DEVICE" ] && [[ ! "$DEVICE" =~ "unauthorized" ]]; then
            adb reverse tcp:5900 tcp:5900 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "📱 ADB reverse configurado!"
                echo "   No VLC do celular: tcp://127.0.0.1:5900"
            fi
        else
            echo "📱 Celular não conectado ou não autorizado"
            echo "   Conecte via Wi-Fi: tcp://$(hostname -I | awk '{print $1}'):5900"
        fi
    fi
}

setup_adb

echo ""
echo "🎵 GurizesSoundboard rodando!"
echo "   Para parar: kill $SOUNDBOARD_PID"
echo ""

# Mantém o script rodando (para uso com systemd)
wait $SOUNDBOARD_PID
