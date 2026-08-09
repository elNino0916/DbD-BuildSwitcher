<p align="center">
  <img
    alt="DbD-BuildSwitcher"
    width="100"
    src="https://github.com/user-attachments/assets/c494b5a1-4b72-431d-8a38-c501db523c4f"
  />
</p>

A lightweight Windows utility for switching between **Dead by Daylight** and **Dead by Daylight - PTB** installations without manually copying the game files yourself.

DbD-BuildSwitcher is designed to make switching between the regular Steam build and the Public Test Build (PTB) quick, simple, and less error-prone.

> **Current Version:** `3.2`

---

## ✨ Features

* 🔄 Switch between the regular **Dead by Daylight** build and the **PTB**
* 📁 Automatically handles the required game files
* 🔎 Detects the Steam installation automatically
* 🛡️ Includes safety checks to help prevent accidental file operations
* 💾 Stores application data in `%LOCALAPPDATA%`
* 📢 Displays an independence / disclaimer notice on first launch
* 🪟 Runs directly from Windows — no additional runtime required
* 🧹 Designed to keep the switching process as simple as possible

---

## 📋 Requirements

* **Windows 10 or later**
* **Steam**
* **Dead by Daylight** installed through Steam
* Sufficient free disk space for the required game files
* Permission to access your Steam library

The tool does not modify the Dead by Daylight game itself.


---

## 🚀 Installation

### 1. Download

Download the latest release from the project's **Releases** page.

### 2. Extract

If the release is provided as an archive, extract it to a location of your choice.

For example:

```text
C:\Tools\DbD-BuildSwitcher\
```

### 3. Run

Launch:

```text
DbD-BuildSwitcher.bat
```

The application will automatically perform its initial checks and guide you through the available options.

---

## 🎮 Usage

Start the application while Steam is closed or when Dead by Daylight is not currently running.

The tool will determine the available Dead by Daylight installations and present the appropriate switching options.

Typical workflow:

```text
Start DbD-BuildSwitcher
        │
        ▼
Detect Steam / Dead by Daylight
        │
        ▼
Select desired build
        │
        ├──► Regular Build
        │
        └──► PTB Build
        │
        ▼
Perform required file operation
        │
        ▼
Launch Steam / Dead by Daylight
```

### ⚠️ Important

**Do not run the switcher while Dead by Daylight is running.**

Steam should also not be downloading or updating Dead by Daylight while a switch is being performed.

---

## 🔐 Safety

DbD-BuildSwitcher performs file operations on your local Dead by Daylight installation.

Because these operations involve a large amount of game data, **do not interrupt the process once a switch has started**.

Recommended:

* Close Dead by Daylight before switching.
* Do not manually modify the game directories during a switch.
* Do not terminate the script while files are being processed.
* Allow Steam to finish pending Dead by Daylight updates before switching.
* Keep enough free storage available for the operation.

If something goes wrong, Steam's **Verify integrity of game files** function can be used to restore missing or corrupted files.

---

## 📂 Application Data

DbD-BuildSwitcher stores its local application data under:

```text
%LOCALAPPDATA%\elNino0916\DbD-BuildSwitcher
```

This may include application state and information used to determine whether the disclaimer has already been displayed.

The application does **not** require an online account.

---

## ❓ Troubleshooting

### The application cannot find Dead by Daylight

Make sure Dead by Daylight is installed through Steam and that the Steam library is accessible.

If Steam is installed in a non-standard location, automatic detection may not be able to find the installation.

### The switch fails

Make sure:

1. Dead by Daylight is closed.
2. Steam is not currently updating the game.
3. You have sufficient free disk space.
4. You have permission to access the Steam library.
5. No other program is modifying the Dead by Daylight directory.

If the game files become inconsistent, use Steam's **Verify integrity of game files** option.

### Steam starts downloading the game again

This can happen if Steam detects that the files currently present do not correspond to the expected version.

Allow Steam to verify the installation before attempting another switch.

---

## 🐛 Reporting Issues

If you encounter a problem, please provide as much information as possible when opening an issue.

Useful information includes:

* DbD-BuildSwitcher version
* Windows version
* Steam installation location
* Whether the regular build or PTB was being selected
* The exact error message
* Relevant console output
* Steps required to reproduce the problem

**Do not upload personal information, Steam credentials, or other sensitive data.**

---

## 📜 Disclaimer

**DbD-BuildSwitcher is an independent fan-made project.**

It is **not affiliated with, endorsed by, sponsored by, or approved by Behaviour Interactive Inc.**

**Dead by Daylight** and related names, characters, logos, and other trademarks are the property of their respective owners.

DbD-BuildSwitcher does not modify, redistribute, or claim ownership of Dead by Daylight or any of its associated intellectual property.

This project is provided as-is and is intended solely as a convenience tool for managing the user's own local game installation.
