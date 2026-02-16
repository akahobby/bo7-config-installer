# BO7 Config Installer

One-click installer for optimized BO7 configuration files.

This script automatically:

- Downloads the latest config package
- Locates the correct Call of Duty "players" folder
- Creates a timestamped backup of existing config files
- Installs the optimized config files
- Provides clear status output during installation

---

## ⚠️ Disclaimer

This tool modifies local configuration files only.  
No game executables or binaries are altered.

Use at your own discretion.

---

## 🚀 Installation

1. Download `BO7_Config_Installer.bat` from this repository.
2. Double-click the file to run it.
3. Allow it to download and install the config files.
4. Launch the game.
5. Select **"No"** on the settings popup.
6. Wait for shaders to finish compiling.

---

## 📦 What Gets Installed

The installer places three configuration files into:

%LOCALAPPDATA%\Activision\Call of Duty\players

If matching files already exist, they are backed up automatically in a folder formatted like:

backup_bo7_YYYY-MM-DD_HH-MM-SS

---

## 🔄 Updating Configs

Configs are versioned using GitHub Releases.

To update:
- Download the latest version of the installer (if updated), or
- Re-run the installer after a new release is published.

---

## 🛠 How It Works

The script:

1. Downloads the config ZIP from GitHub Releases.
2. Extracts the required files to a temporary folder.
3. Locates the correct "players" directory automatically.
4. Backs up existing files (if found).
5. Copies the new config files into place.

No manual file navigation required.

---

## 🧾 License

This project is released under the MIT License.

You are free to use, modify, and distribute it.
