#!/bin/bash
# Mil4ne - Pwni-Conf

set -e

LOGFILE="$HOME/install.log"
exec > >(tee "$LOGFILE") 2>&1

# =========================
# Colors
# =========================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# =========================
# Banner
# =========================
clear
echo -e "${BLUE}"
cat << "EOF"
██████╗ ██╗    ██╗███╗   ██╗██╗       ██████╗ ██████╗ ███╗   ██╗███████╗
██╔══██╗██║    ██║████╗  ██║██║      ██╔════╝██╔═══██╗████╗  ██║██╔════╝
██████╔╝██║ █╗ ██║██╔██╗ ██║██║█████╗██║     ██║   ██║██╔██╗ ██║█████╗
██╔═══╝ ██║███╗██║██║╚██╗██║██║╚════╝██║     ██║   ██║██║╚██╗██║██╔══╝
██║     ╚███╔███╔╝██║ ╚████║██║      ╚██████╗╚██████╔╝██║ ╚████║██║
╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝

                    P w n i - C o n f
EOF
echo -e "${RESET}"

echo -e "${GREEN}[*] Starting installation...${RESET}"

# =========================
# VALIDATIONS
# =========================
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[!] Do not run as root${RESET}"
  exit 1
fi

command -v apt >/dev/null || { echo "[!] apt not found"; exit 1; }

BASE_DIR="$HOME/custom-linux-workspace"
[ -d "$BASE_DIR" ] || { echo "[!] custom-linux-workspace not found"; exit 1; }

# =========================
# UPGRADE PROMPT
# =========================
read -rp "$(echo -e "${YELLOW}Do you want to upgrade system packages first? [y/N]: ${RESET}")" UPGRADE

sudo apt update
if [[ "$UPGRADE" =~ ^[Yy]$ ]]; then
  sudo apt upgrade -y
fi

# =========================
# CORE PACKAGES
# =========================
sudo apt install -y \
  xorg xinit x11-xserver-utils \
  bspwm sxhkd \
  alacritty polybar rofi \
  tmux feh \
  dunst wmname \
  lsd bat curl git unzip wget \
  fonts-font-awesome \
  fonts-materialdesignicons-webfont unifont \
  tmux numlockx \
  pulseaudio-utils pavucontrol \
  brightnessctl \
  open-vm-tools open-vm-tools-desktop \
  build-essential \
  zsh \
  libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
  libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
  libxcb-xtest0-dev libxcb-shape0-dev

# =========================
# CONFIG DIRS
# =========================
for dir in bspwm sxhkd polybar rofi alacritty picom dunst; do
  mkdir -p "$HOME/.config/$dir"
done

mkdir -p "$HOME/Wallpapers" "$HOME/.local/share/fonts"

# =========================
# COPY CONFIGS
# =========================
for cfg in bspwm sxhkd polybar rofi alacritty picom dunst; do
  [ -d "$BASE_DIR/config/$cfg" ] && cp -r "$BASE_DIR/config/$cfg" "$HOME/.config/"
done

chmod +x "$HOME/.config/bspwm/bspwmrc"
chmod +x "$HOME/.config/polybar/launch.sh"
chmod +x "$HOME/.config/bspwm/scripts/"* 2>/dev/null || true

# =========================
# NERD FONT
# =========================
FONT_DIR1="$HOME/.local/share/fonts/JetBrainsMono"

if [ ! -d "$FONT_DIR1" ]; then
  echo -e "${GREEN}[+] Installing JetBrainsMono Nerd Font...${RESET}"
  mkdir -p "$FONT_DIR1"
  cd /tmp
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -q JetBrainsMono.zip -d "$FONT_DIR1"
  rm JetBrainsMono.zip
fi

FONT_DIR2="$HOME/.local/share/fonts/CascadiaCode"

if [ ! -d "$FONT_DIR2" ]; then
  echo -e "${GREEN}[+] Installing CascadiaCode Font...${RESET}"
  mkdir -p "$FONT_DIR2"
  cd /tmp
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
  unzip -q CascadiaCode.zip -d "$FONT_DIR2"
  rm CascadiaCode.zip
fi

fc-cache -fv > /dev/null

# =========================
# OH MY ZSH (USER)
# =========================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true

[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
cp "$BASE_DIR/.zshrc" "$HOME/.zshrc"

# =========================
# OH MY ZSH (ROOT)
# =========================
if [ ! -d "/root/.oh-my-zsh" ]; then
  echo -e "${GREEN}[+] Installing Oh My Zsh for root...${RESET}"
  sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# =========================
# POWERLEVEL10K
# =========================
echo -e "${GREEN}[+] Installing Powerlevel10k...${RESET}"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "$ZSH_CUSTOM/themes/powerlevel10k" || true

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  /root/.oh-my-zsh/custom/themes/powerlevel10k || true

sudo sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc || true

# =========================
# DEFAULT SHELL
# =========================
chsh -s $(which zsh)
sudo chsh -s $(which zsh) root

# =========================
# VMWARE OPTIMIZATIONS
# =========================
echo -e "${BLUE}[*] Applying VMware optimizations...${RESET}"

sudo systemctl start vmtoolsd

cat <<EOF > "$HOME/.xprofile"
xset s off
xset -dpms
xset s noblank
EOF

if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
  echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
fi

# =========================
# DONE
# =========================
echo
echo "======================================="
echo " Instalacion completa"
echo "======================================="
echo
echo "[+] Log file: $LOGFILE"
echo "[+] Reboot recommended"
