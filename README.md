# OpenCode Portable Builder

A lightweight PowerShell script that builds a portable [**OpenCode**](https://opencode.ai/) package following the [PortableApps.com](https://portableapps.com/) directory structure, ready for use with **PortableApps.com Launcher Generator**.

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

<sub>Built for a clean, self-contained OpenCode experience on Windows.</sub>
