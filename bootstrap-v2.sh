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
  build-essential \
  ca-certificates \
  gnupg \
  lsb-release \
  ufw \
  fail2ban \
  nginx

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
# 10. JS Tooling
# ----------------------------
echo "⚡ Installing JS tooling..."

npm install -g pnpm
curl -fsSL https://bun.sh/install | bash

npm install -g turbo nx pm2

# ----------------------------
# 11. Install Docker
# ----------------------------
echo "🐳 Installing Docker..."

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker $USER

# ----------------------------
# 12. Firewall (UFW)
# ----------------------------
echo "🔥 Configuring UFW..."

ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# ----------------------------
# 13. Fail2Ban
# ----------------------------
echo "🛡 Installing Fail2Ban..."

systemctl enable fail2ban
systemctl start fail2ban

# ----------------------------
# 14. SSH Hardening
# ----------------------------
echo "🔐 Hardening SSH..."

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

systemctl restart ssh

# ----------------------------
# 15. Nginx
# ----------------------------
echo "🌐 Setting up Nginx..."

systemctl enable nginx
systemctl start nginx

# ----------------------------
# 16. Done
# ----------------------------
echo "✅ Bootstrap complete!"

echo ""
echo "👉 Run: exec zsh"
echo "👉 Then: p10k configure"
echo "👉 Log out & back in for Docker permissions"
