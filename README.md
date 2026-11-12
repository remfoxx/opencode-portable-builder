<div align="center">

**Fully isolated, zero-dependency, self-contained runtime environment OpenCode CLI setup.**

```
    ███  ████  █████ █   █  ███   ███  ████  █████    ████   ███  ████  █████  ███  ████  █     █████   
   █ ░░█ █░░░█ █░░░░░██  █░█ ░░░ █ ░░█ █░░░█ █░░░░░   █░░░█ █ ░░█ █░░░█  ░█░░░█ ░░█ █░░░█ █░    █░░░░░  
   █░ ░█░████░░████░░█░█ █░█░ ░░░█░ ░█░█░░░█░████░░░  ████░░█░ ░█░████░░  █░░░█████░████░░█░░   ████░░░ 
   █░░ █░█░░░░ █░░░░ █░░██░█░░   █░░ █░█░░ █░█░░░░    █░░░░ █░░ █░█░░█░ ░ █░░ █░░░█░█░░░█ █░░   █░░░░   
    ███ ░█░░░░░█████░█░░ █░░███   ███ ░████ ░█████░   █░░░░░ ███ ░█░░░█░  █░░ █░░░█░████░░█████ █████░  
     ░░░ ░░░    ░░░░░ ░░  ░░ ░░░   ░░░ ░░░░░ ░░░░░░    ░░     ░░░ ░░░  ░   ░░  ░░  ░░░░░░ ░░░░░░ ░░░░░  
```

[![Platform](https://img.shields.io/badge/Platform-Windows%20x64-0078D6?logo=windows&logoColor=white)](#)
[![Shell](https://img.shields.io/badge/Shell-PowerShell%205.1%2B-5391FE?logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Runtime](https://img.shields.io/badge/Node.js-LTS%20Portable-339933?logo=node.js&logoColor=white)](https://nodejs.org/en)
[![Package](https://img.shields.io/badge/CLI-@opencode/cli-blue?logo=npm&logoColor=white)](https://www.npmjs.com/package/@opencode/cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

# OpenCode Portable Builder

A lightweight PowerShell script that builds a portable [**OpenCode**](https://opencode.ai/) package following the [PortableApps.com](https://portableapps.com/) directory structure, ready for use with **PortableApps.com Launcher Generator**. Built for a clean, self-contained OpenCode experience.

## Features

- Downloads the latest OpenCode CLI release via npm.
- Extracts the native Windows x64 executable.
- Generates the PortableApps-compatible directory structure and configuration files.
- Creates a multi-resolution application icon (ICO).
- Redirects XDG configuration, data, cache and state directories to the portable `Data` folder.
- Disables OpenCode automatic updates.
- Verifies the generated package and removes temporary build files.

## Requirements

- Windows 10/11 (x64)
- Windows PowerShell 5.1 or later
- [Node.js](https://nodejs.org/) (includes npm)
- Internet connection

## Usage

1. Create an empty working directory (e.g. `OpenCodePortable`).
2. Place `build.ps1` inside the directory.
3. Run the script using Windows PowerShell.
4. Wait for the build process to complete.
5. The generated package will be available in the `OpenCodePortable` subdirectory.
6. Download and install [PortableApps.com Launcher](https://portableapps.com/apps/development/portableapps.com_launcher).
7. Open **PortableApps.com Launcher Generator**, select the generated `OpenCodePortable` directory and follow the packaging instructions.

**Note:** The script only builds the application directory structure. PortableApps.com Launcher Generator is required to create the final portable launcher executable.

## Output Structure

```text
OpenCodePortable/
├── App/
│   ├── AppInfo/
│   │   └── Launcher/
│   └── OpenCode/
├── Data/
│   ├── cache/
│   ├── config/
│   ├── data/
│   └── state/
└── Other/
    └── Source/
```

The generated package keeps OpenCode's configuration and runtime data inside its own directory, making it suitable for portable deployment.

---

<sub>
Unofficial tool. Not affiliated with, endorsed, or sponsored by OpenCode or Anomaly.
</sub>
