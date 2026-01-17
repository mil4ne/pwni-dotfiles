# Mil4ne - Auto Install
#!/bin/bash

set -e

sudo apt update
sudo apt install -y bspwm sxhkd alacritty polybar rofi xcompmgr feh lsd numlockx bat curl fonts-materialdesignicons-webfont unifont tmux

for dir in bspwm sxhkd polybar rofi alacritty; do
  mkdir -p "$HOME/.config/$dir"
done

mkdir -p "$HOME/Wallpapers" "$HOME/.local/share/fonts"

for cfg in bspwm sxhkd polybar alacritty; do
  cp -r "$HOME/custom-linux-workspace/config/$cfg" "$HOME/.config"
done

chmod +x "$HOME/.config/bspwm/bspwmrc"
chmod +x "$HOME/.config/polybar/launch.sh"

cp "$HOME/custom-linux-workspace/wallpapers/ber.jpg" "$HOME/Wallpapers"
cp -r "$HOME/custom-linux-workspace/fonts" "$HOME/.local/share/fonts"
# cd $HOME/.local/share/fonts
# wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
# unzip JetBrainsMono.zip -d JetBrainsMono
# rm JetBrainsMono.zip
# cd .

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" || true

rm -rf ~/.zshrc
cp "$HOME/custom-linux-workspace/.zshrc" "$HOME/.zshrc"

# Instalando Oh my Zsh
rm -rf /home/$(whoami)/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

alacritty migrate || true

sudo chmod +x "$HOME/.config/bspwm/scripts/bspwm_resize" || true

