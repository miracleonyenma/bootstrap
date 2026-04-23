# 🚀 Bootstrap Script

A production-ready bootstrap script to set up a fresh Ubuntu server for modern JavaScript development and deployment.

---

## 📦 What We’re Setting Up

We automate everything needed to go from a fresh server → fully usable dev + deployment environment.

### 🧰 Core System
- System update & essential packages
- Zsh as default shell

### 🐚 Shell Experience
- Oh My Zsh
- Powerlevel10k theme
- Plugins:
  - autosuggestions
  - syntax highlighting

### 🟢 Node Environment
- NVM (Node Version Manager)
- Latest LTS Node.js
- Global tooling:
  - pnpm
  - bun
  - turbo
  - nx
  - pm2

### 🐳 Containers
- Docker
- Docker Compose (plugin)

### 🔐 Server Hardening
- UFW firewall (SSH + HTTP/HTTPS)
- Fail2Ban (basic intrusion protection)
- SSH hardening:
  - Disable root login
  - Disable password auth

### 🌐 Deployment Stack
- Nginx (enabled + running)
- PM2 (process manager for Node apps)

---

## ⚙️ Requirements

- Ubuntu/Debian-based system
- Root or sudo access

---

## ▶️ Usage

### Clone & run

```bash
git clone https://github.com/miracleonyenma/bootstrap.git
cd bootstrap/v2
chmod +x bootstrap.sh
./bootstrap.sh
````

### Or run directly

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/miracleonyenma/bootstrap/main/v2/bootstrap.sh)
```

---

## 🧠 Post-Setup Steps

After the script completes:

```bash
exec zsh
p10k configure
```

Also:

* Log out and back in (for Docker group permissions)
* Point your domain to your server
* Configure Nginx for your app
* Add SSL using Certbot (recommended next step)

---

## 🔒 Security Notes

We:

* Disable SSH password authentication
* Disable root SSH login
* Enable firewall (UFW)
* Install Fail2Ban

Make sure you:

* Have SSH key access set up before running this on a remote server

---

## 🧪 Idempotency

The script is mostly safe to re-run:

* Uses `|| true` for git clones
* Overwrites `.zshrc`

You can improve it further by adding checks before installs.

---

## 🔧 Customization Ideas

We can extend this further by:

* Adding PostgreSQL / MongoDB
* Automating SSL with Certbot
* Adding CI/CD hooks
* Pre-configuring Nginx reverse proxies

---

## 📄 License

MIT


