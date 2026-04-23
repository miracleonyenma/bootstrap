#!/usr/bin/env bash

set -e

echo "🚀 Starting bootstrap..."

# ----------------------------
# 1. Update system
# ----------------------------
echo "📦 Updating system..."
apt update -y && apt upgrade -y

# ----------------------------
# 2. Install base packages
# ----------------------------
echo "🛠 Installing base packages..."
apt install -y \
  zsh \
  git \
  curl \
  wget \
  unzip \
  build-essential

# ----------------------------
# 3. Set Zsh as default shell
# ----------------------------
echo "🐚 Setting Zsh as default shell..."
chsh -s $(which zsh)

# ----------------------------
# 4. Install Oh My Zsh
# ----------------------------
echo "✨ Installing Oh My Zsh..."
export RUNZSH=no
export CHSH=no

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ----------------------------
# 5. Install Powerlevel10k
# ----------------------------
echo "🎨 Installing Powerlevel10k..."

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  $ZSH_CUSTOM/themes/powerlevel10k || true

# ----------------------------
# 6. Install plugins
# ----------------------------
echo "🔌 Installing Zsh plugins..."

git clone https://github.com/zsh-users/zsh-autosuggestions \
  $ZSH_CUSTOM/plugins/zsh-autosuggestions || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true

# ----------------------------
# 7. Configure .zshrc
# ----------------------------
echo "⚙️ Configuring Zsh..."

cat > ~/.zshrc <<'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

# ----------------------------
# 8. Install NVM
# ----------------------------
echo "🟢 Installing NVM..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ----------------------------
# 9. Install Node LTS
# ----------------------------
echo "📦 Installing Node LTS..."

nvm install --lts
nvm use --lts
nvm alias default "lts/*"

# ----------------------------
# 10. Done
# ----------------------------
echo "✅ Bootstrap complete!"

echo ""
echo "👉 Run: exec zsh"
echo "👉 Then: p10k configure"
