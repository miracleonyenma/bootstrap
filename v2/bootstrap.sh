#!/usr/bin/env bash

set -euo pipefail

echo "🚀 Starting production bootstrap..."

# ----------------------------
# Helpers
# ----------------------------
log() { echo -e "\n👉 $1"; }
ok() { echo "✅ $1"; }
warn() { echo "⚠️ $1"; }

# ----------------------------
# 0. Preflight checks
# ----------------------------
log "Running preflight checks..."

if [ "$EUID" -ne 0 ]; then
  warn "Please run as root (sudo)"
  exit 1
fi

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
TARGET_USER=${SUDO_USER:-$USER}

ok "Running as root. Target user: $TARGET_USER"

# ----------------------------
# 1. System update
# ----------------------------
log "Updating system packages..."

apt update -y
apt upgrade -y

ok "System updated"

# ----------------------------
# 2. Install base packages (idempotent)
# ----------------------------
log "Installing base packages..."

PACKAGES=(
  zsh git curl wget unzip build-essential
  ca-certificates gnupg lsb-release
  ufw fail2ban nginx
)

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    ok "$pkg already installed"
  else
    apt install -y "$pkg"
  fi
done

# ----------------------------
# 3. Zsh setup
# ----------------------------
log "Configuring Zsh..."

if ! grep -q "$(which zsh)" /etc/shells; then
  echo "$(which zsh)" >> /etc/shells
fi

if [ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)" "$TARGET_USER"
  ok "Zsh set as default shell"
else
  ok "Zsh already default"
fi

# ----------------------------
# 4. Oh My Zsh (safe install)
# ----------------------------
log "Installing Oh My Zsh..."

if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
  sudo -u "$TARGET_USER" sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# ----------------------------
# 5. Powerlevel10k + plugins
# ----------------------------
log "Installing Zsh plugins..."

ZSH_CUSTOM="$USER_HOME/.oh-my-zsh/custom"

clone_if_missing () {
  if [ ! -d "$2" ]; then
    git clone --depth=1 "$1" "$2"
    ok "Installed $(basename "$2")"
  else
    ok "$(basename "$2") already exists"
  fi
}

clone_if_missing https://github.com/romkatv/powerlevel10k.git \
  "$ZSH_CUSTOM/themes/powerlevel10k"

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ----------------------------
# 6. Zsh config (non-destructive)
# ----------------------------
log "Configuring .zshrc..."

ZSHRC="$USER_HOME/.zshrc"

if ! grep -q "powerlevel10k" "$ZSHRC" 2>/dev/null; then
  cat <<'EOF' >> "$ZSHRC"

# --- Custom Setup ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
  ok ".zshrc updated"
else
  ok ".zshrc already configured"
fi

# ----------------------------
# 7. NVM + Node
# ----------------------------
log "Installing Node via NVM..."

if [ ! -d "$USER_HOME/.nvm" ]; then
  sudo -u "$TARGET_USER" bash -c \
    "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
fi

export NVM_DIR="$USER_HOME/.nvm"
source "$NVM_DIR/nvm.sh"

if ! command -v node &>/dev/null; then
  nvm install --lts
  nvm alias default "lts/*"
  ok "Node installed"
else
  ok "Node already installed"
fi

# ----------------------------
# 8. Global JS tooling
# ----------------------------
log "Installing JS tooling..."

npm install -g pnpm turbo nx pm2 || true

if ! command -v bun &>/dev/null; then
  curl -fsSL https://bun.sh/install | bash
fi

# ----------------------------
# 9. Docker (idempotent)
# ----------------------------
log "Installing Docker..."

if ! command -v docker &>/dev/null; then
  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt update -y
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  ok "Docker installed"
else
  ok "Docker already installed"
fi

usermod -aG docker "$TARGET_USER"

# ----------------------------
# 10. Firewall (safe)
# ----------------------------
log "Configuring UFW..."

ufw allow OpenSSH
ufw allow 'Nginx Full'

if ! ufw status | grep -q "Status: active"; then
  ufw --force enable
  ok "UFW enabled"
else
  ok "UFW already active"
fi

# ----------------------------
# 11. Fail2Ban
# ----------------------------
log "Configuring Fail2Ban..."

systemctl enable fail2ban
systemctl restart fail2ban

# ----------------------------
# 12. SSH Hardening (SAFE)
# ----------------------------
log "Hardening SSH..."

SSH_CONFIG="/etc/ssh/sshd_config"
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"

sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' $SSH_CONFIG

if [ -s "$USER_HOME/.ssh/authorized_keys" ]; then
  warn "SSH key detected → disabling password auth"
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' $SSH_CONFIG
else
  warn "No SSH key → keeping password auth ENABLED"
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' $SSH_CONFIG
fi

systemctl restart ssh

# ----------------------------
# 13. Nginx
# ----------------------------
log "Ensuring Nginx is running..."

systemctl enable nginx
systemctl restart nginx

# ----------------------------
# Done
# ----------------------------
echo ""
echo "🎉 Bootstrap complete!"
echo "👉 Run: exec zsh"
echo "👉 Then: p10k configure"
echo "👉 Re-login for Docker permissions"
