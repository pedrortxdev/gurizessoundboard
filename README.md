# 🎛️ GurizesSoundboard

Transforma o **Numpad** do seu teclado em uma mesa de som quando o **NumLock está DESLIGADO**.

> Desenvolvido com Tauri v2 (Rust + React + TypeScript) para Linux.

## ✨ Features

- 🎹 **Numpad como Soundboard**: Cada tecla do numpad pode ter um som associado
- 🔒 **NumLock Toggle**: Só funciona quando NumLock está OFF (preserva função normal)
- 🎵 **Audio Overlapping**: Múltiplos sons podem tocar simultaneamente
- 💾 **Persistência**: Configurações salvas automaticamente
- 🎨 **Visual Feedback**: Teclas acendem quando pressionadas
- 🔊 **Controle de Volume**: Master volume integrado

## 📦 Dependências (Arch Linux)

```bash
# Dependências de desenvolvimento
sudo pacman -S rust nodejs npm webkit2gtk-4.1 libayatana-appindicator

# Áudio (PipeWire)
sudo pacman -S pipewire pipewire-pulse wireplumber

# Opcional: para gerenciar virtual sinks
sudo pacman -S qpwgraph
```

## 🔧 Configuração de Permissões

O app precisa acessar dispositivos de input (`/dev/input/event*`). Execute:

```bash
# Script automático
sudo ./scripts/setup-udev.sh

# Ou manualmente:
sudo usermod -aG input $USER
echo 'KERNEL=="event*", SUBSYSTEM=="input", MODE="0664", GROUP="input"' | \
  sudo tee /etc/udev/rules.d/99-gurizes-input.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

**⚠️ Faça logout e login novamente para aplicar as mudanças de grupo.**

## 🚀 Executando

```bash
# Instalar dependências
npm install

# Modo desenvolvimento
npm run tauri dev

# Build de produção
npm run tauri build
```

## 🎧 Configuração PipeWire (VOIP)

Para capturar o áudio em Discord/Teams, crie um Virtual Sink:

### Método 1: Linha de comando

```bash
# Criar Virtual Sink
pactl load-module module-null-sink sink_name=Soundboard sink_properties=device.description="GurizesSoundboard"

# No Discord/Teams: Settings → Voice → Input Device → "Monitor of Soundboard"
```

### Método 2: qpwgraph

1. Abra `qpwgraph`
2. Conecte o output do GurizesSoundboard ao Virtual Sink
3. Configure o app de VOIP para usar o monitor do Virtual Sink

### Tornar Persistente

Adicione ao `~/.config/pipewire/pipewire.conf.d/soundboard.conf`:

```ini
context.exec = [
  { path = "pactl" args = "load-module module-null-sink sink_name=Soundboard sink_properties=device.description=GurizesSoundboard" }
]
```

## 🎮 Como Usar

1. **Selecione o teclado** na tela inicial (procure por dispositivos com "Numpad ✓")
2. **Clique em uma tecla** para atribuir um arquivo de áudio (.mp3, .wav, .ogg, .flac)
3. **Desligue o NumLock** no teclado
4. **Pressione as teclas** do numpad para tocar os sons!
5. **Clique direito** em uma tecla para remover o som atribuído

## 🏗️ Arquitetura

```
src-tauri/
├── src/
│   ├── main.rs          # Entrypoint Tauri
│   ├── lib.rs           # Comandos Tauri
│   ├── input/           # Módulo de input
│   │   ├── device.rs    # Enumeração de dispositivos
│   │   └── monitor.rs   # Monitor de teclado (evdev)
│   ├── audio/           # Módulo de áudio
│   │   └── player.rs    # Engine de playback (rodio)
│   └── config/          # Módulo de configuração
│       └── store.rs     # Mapeamento tecla→som
src/
├── App.tsx              # Componente principal React
├── index.css            # Estilos TailwindCSS
└── main.tsx             # Entrypoint React
```

## 📝 Licença

GNU GPL v3
