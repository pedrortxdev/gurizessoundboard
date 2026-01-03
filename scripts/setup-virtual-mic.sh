#!/bin/bash
# GurizesSoundboard - Virtual Audio Setup V4
# 
# Configuração:
#   SAÍDA (você ouve): Áudio normal + Soundboard → Sua saída padrão
#   ENTRADA (Discord): Seu microfone padrão + Soundboard → Mic Virtual
#
# Arquitetura:
#   [Soundboard App] → [Soundboard Sink] ─┬─→ [Sua Saída Padrão] (você ouve)
#                                          └─→ [Mixer] → [VirtualMic] → Discord
#   [Mic Padrão] ───────────────────────────→ [Mixer] ↗

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     GurizesSoundboard - Configuração de Áudio Virtual V4     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Cleanup
echo "🧹 Limpando configuração anterior..."
pactl unload-module module-null-sink 2>/dev/null || true
pactl unload-module module-loopback 2>/dev/null || true
pactl unload-module module-remap-source 2>/dev/null || true
sleep 0.5

# Detect default devices
DEFAULT_SINK=$(pactl get-default-sink)
DEFAULT_SOURCE=$(pactl get-default-source)

# Get friendly names
DEFAULT_SINK_NAME=$(pactl list sinks | grep -A1 "Name: $DEFAULT_SINK" | grep "Description:" | cut -d: -f2- | xargs)
DEFAULT_SOURCE_NAME=$(pactl list sources | grep -A1 "Name: $DEFAULT_SOURCE" | grep "Description:" | cut -d: -f2- | xargs)

echo "🔊 Saída padrão detectada:"
echo "   → $DEFAULT_SINK_NAME"
echo "   → ($DEFAULT_SINK)"
echo ""
echo "🎤 Microfone padrão detectado:"
echo "   → $DEFAULT_SOURCE_NAME"
echo "   → ($DEFAULT_SOURCE)"
echo ""

# ============================================================================
# Step 1: Create Soundboard sink (where the app sends audio)
# ============================================================================
echo "🔊 Criando sink do Soundboard..."
SB_SINK=$(pactl load-module module-null-sink \
    sink_name=Soundboard \
    sink_properties=device.description="GurizesSoundboard_Output")
echo "   ✓ Sink criado (ID: $SB_SINK)"

# ============================================================================
# Step 2: Loopback Soundboard → Default Sink (so YOU can hear the sounds)
# ============================================================================
echo "🎧 Conectando Soundboard → Sua saída padrão..."
LB_TO_HEADPHONES=$(pactl load-module module-loopback \
    source=Soundboard.monitor \
    sink="$DEFAULT_SINK" \
    latency_msec=30)
echo "   ✓ Você vai ouvir os sons do soundboard! (ID: $LB_TO_HEADPHONES)"

# ============================================================================
# Step 3: Create mixer sink (combines mic + soundboard for Discord)
# ============================================================================
echo "🎤 Criando mixer Mic+Soundboard..."
MIXER=$(pactl load-module module-null-sink \
    sink_name=MicMixer \
    sink_properties=device.description="Mic_Soundboard_Mixer")
echo "   ✓ Mixer criado (ID: $MIXER)"

# ============================================================================
# Step 4: Loopback Default Mic → Mixer
# ============================================================================
echo "🔗 Conectando seu microfone padrão → Mixer..."
LB_MIC=$(pactl load-module module-loopback \
    source="$DEFAULT_SOURCE" \
    sink=MicMixer \
    latency_msec=30 \
    source_dont_move=true)
echo "   ✓ Mic conectado (ID: $LB_MIC)"

# ============================================================================
# Step 5: Loopback Soundboard → Mixer
# ============================================================================
echo "🔗 Conectando Soundboard → Mixer..."
LB_SB=$(pactl load-module module-loopback \
    source=Soundboard.monitor \
    sink=MicMixer \
    latency_msec=30)
echo "   ✓ Soundboard conectado ao mixer (ID: $LB_SB)"

# ============================================================================
# Step 6: Create Virtual Mic source from mixer
# ============================================================================
echo "🎙️ Criando microfone virtual..."
VMIC=$(pactl load-module module-remap-source \
    master=MicMixer.monitor \
    source_name=VirtualMic \
    source_properties=device.description="Microfone_Virtual_Soundboard")
echo "   ✓ VirtualMic criado! (ID: $VMIC)"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   ✅ CONFIGURAÇÃO CONCLUÍDA!                 ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  🎧 VOCÊ OUVE: Sons normais + Soundboard na sua saída padrão ║"
echo "║     → Atualmente: $DEFAULT_SINK_NAME"
echo "║                                                              ║"
echo "║  🎤 DISCORD OUVE: Seu mic padrão + Soundboard                ║"
echo "║     → Selecione 'Microfone_Virtual_Soundboard' no Discord    ║"
echo "║     → Mic atual: $DEFAULT_SOURCE_NAME"
echo "║                                                              ║"
echo "║  📌 No pavucontrol (aba Playback):                           ║"
echo "║     → GurizesSoundboard → 'GurizesSoundboard_Output'         ║"
echo "║                                                              ║"
echo "║  💡 Para trocar o microfone fonte:                           ║"
echo "║     1. Mude o microfone padrão do sistema                    ║"
echo "║     2. Execute este script novamente                         ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Set VirtualMic as default
pactl set-default-source VirtualMic
echo "✓ VirtualMic definido como microfone padrão do sistema"
echo ""
echo "🛑 Para desfazer: ./scripts/teardown-audio.sh"

# Save for teardown
SCRIPT_DIR="$(dirname "$0")"
cat > "$SCRIPT_DIR/audio-modules.txt" << EOF
SB_SINK=$SB_SINK
LB_TO_HEADPHONES=$LB_TO_HEADPHONES
MIXER=$MIXER
LB_MIC=$LB_MIC
LB_SB=$LB_SB
VMIC=$VMIC
ORIGINAL_SOURCE=$DEFAULT_SOURCE
EOF
