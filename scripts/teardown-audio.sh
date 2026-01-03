#!/bin/bash
# GurizesSoundboard - Remove Virtual Audio Setup

SCRIPT_DIR="$(dirname "$0")"
MODULES_FILE="$SCRIPT_DIR/audio-modules.txt"

echo "🛑 Removendo configuração de áudio virtual..."

if [ -f "$MODULES_FILE" ]; then
    source "$MODULES_FILE"
    
    # Restore original mic as default
    if [ -n "$ORIGINAL_SOURCE" ]; then
        pactl set-default-source "$ORIGINAL_SOURCE" 2>/dev/null && echo "   ✓ Mic padrão restaurado: $ORIGINAL_SOURCE"
    fi
    
    # Unload in reverse order
    [ -n "$VMIC" ] && pactl unload-module "$VMIC" 2>/dev/null && echo "   ✓ VirtualMic removido"
    [ -n "$LB_SB" ] && pactl unload-module "$LB_SB" 2>/dev/null && echo "   ✓ Loopback SB removido"
    [ -n "$LB_MIC" ] && pactl unload-module "$LB_MIC" 2>/dev/null && echo "   ✓ Loopback Mic removido"
    [ -n "$MIXER" ] && pactl unload-module "$MIXER" 2>/dev/null && echo "   ✓ Mixer removido"
    [ -n "$LB_TO_HEADPHONES" ] && pactl unload-module "$LB_TO_HEADPHONES" 2>/dev/null && echo "   ✓ Loopback fone removido"
    [ -n "$SB_SINK" ] && pactl unload-module "$SB_SINK" 2>/dev/null && echo "   ✓ Soundboard sink removido"
    
    rm -f "$MODULES_FILE"
    echo ""
    echo "✅ Configuração de áudio virtual removida!"
else
    echo "⚠️  Arquivo não encontrado, tentando limpeza geral..."
    pactl unload-module module-remap-source 2>/dev/null || true
    pactl unload-module module-loopback 2>/dev/null || true
    pactl unload-module module-null-sink 2>/dev/null || true
    echo "✅ Feito."
fi
