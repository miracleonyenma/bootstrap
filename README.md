
# 🚀 Bootstrap Script

A simple shell script to quickly set up a fresh development environment with essential tools, runtimes, and configurations.

## 📦 Overview

This project provides a `bootstrap.sh` script that automates the installation and setup of common development dependencies. It’s designed to save time when provisioning a new machine or resetting your environment.

Instead of manually installing everything step by step, we can run a single command and get a ready-to-use setup.

---

## ⚙️ What This Script Does

Depending on what you’ve included in your script, this typically covers:

* Installing system dependencies
* Installing and configuring Node.js via NVM (Node Version Manager)
* Setting a default Node version (LTS)
* Installing global npm packages
* Setting up shell configuration (`.zshrc`, `.bashrc`, etc.)
* Any additional tooling (Git, Docker, etc.)

> You can expand this section as your script evolves.

---

## 🛠 Requirements

Before running the script, ensure:

* You are on a Unix-based system (Linux/macOS)
* You have:

  * `curl` or `wget`
  * `bash` or `zsh`

---

## ▶️ Usage

### 1. Clone the repository

```bash
git clone https://github.com/miracleonyenma/bootstrap.git
cd bootstrap
```

### 2. Make the script executable

```bash
chmod +x bootstrap.sh
```

### 3. Run the script

```bash
./bootstrap.sh
```

---

## 🔁 Alternative: Run directly from GitHub

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/miracleonyenma/bootstrap/main/bootstrap.sh)
```

---

## 🧠 Notes

* The script installs the latest LTS version of Node using NVM:

  ```bash
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
  ```
* If you see an error like:

  ```
  zsh: no matches found: lts/*
  ```

  This is a shell globbing issue in `zsh`, not an actual failure. Node is still installed correctly.

  You can fix it by quoting:

  ```bash
  nvm alias default "lts/*"
  ```

---

## 🔧 Customization

We can modify `bootstrap.sh` to fit specific needs:

* Add project-specific dependencies
* Install databases (PostgreSQL, MongoDB, etc.)
* Configure environment variables
* Set up SSH keys or Git configs

---

## 🧪 Idempotency

Ideally, the script should be safe to run multiple times without breaking your system. If you’re extending it, consider:

* Checking if a tool is already installed before installing
* Avoiding duplicate entries in config files

---

## 📁 Project Structure

```
.
├── bootstrap.sh
└── README.md
```

---

## 🤝 Contributing

Feel free to fork this repo and tailor it to your workflow. If you find improvements, open a PR.

---

## 📄 License

MIT

---

