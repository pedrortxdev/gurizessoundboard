#!/bin/bash
# GurizesSoundboard - udev Rules Setup Script
# This script creates the udev rules necessary to access input devices without root

set -e

RULE_FILE="/etc/udev/rules.d/99-gurizes-input.rules"
RULE_CONTENT='# GurizesSoundboard - Allow input device access for users in "input" group
KERNEL=="event*", SUBSYSTEM=="input", MODE="0664", GROUP="input"'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        GurizesSoundboard - Configuração de Permissões        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado com sudo:"
    echo "   sudo $0"
    exit 1
fi

# Create the input group if it doesn't exist
if ! getent group input > /dev/null 2>&1; then
    echo "📁 Criando grupo 'input'..."
    groupadd input
fi

# Get the current user (the one who called sudo)
REAL_USER="${SUDO_USER:-$USER}"

# Add user to input group
echo "👤 Adicionando usuário '$REAL_USER' ao grupo 'input'..."
usermod -aG input "$REAL_USER"

# Create udev rule
echo "📝 Criando regra udev em $RULE_FILE..."
echo "$RULE_CONTENT" > "$RULE_FILE"

# Reload udev rules
echo "🔄 Recarregando regras udev..."
udevadm control --reload-rules
udevadm trigger

echo ""
echo "✅ Configuração concluída!"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  IMPORTANTE: Faça logout e login novamente para aplicar as   ║"
echo "║  mudanças de grupo, ou execute:                              ║"
echo "║                                                              ║"
echo "║    newgrp input                                              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
