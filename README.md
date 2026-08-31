<div align="center">
  <img src="https://raw.githubusercontent.com/wako69420/IconChanger/main/IconChangerAppIcon.png" alt="Icon Changer Logo" width="128" />
  <h1>macOS Icon Changer</h1>
  <p><strong>A native, one-click solution to customize files, folders, and applications on macOS.</strong></p>

  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  [![Platform: macOS](https://img.shields.io/badge/Platform-macOS%2011%2B-lightgrey.svg)]()
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-Apple-orange.svg)]()
</div>

<br/>

<div align="center">
  <img src="https://raw.githubusercontent.com/wako69420/IconChanger/main/demo.gif" alt="Icon Changer Demo" width="700" style="border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);" />
</div>

<br/>

## How to Download

If you aren't familiar with GitHub, downloading the app is simple!

1. Click here to go to the **[Latest Release](https://github.com/wako69420/IconChanger/releases/latest)** page.
2. Scroll down to the **Assets** section at the bottom of the release notes.
3. Click on the **`.dmg`** file (e.g., `IconChanger-v1.1.3.dmg`) to download the app.
4. Double-click the downloaded file and drag **Icon Changer** into your Applications folder.

---

## ⚠️ Note

Some apps might react negatively with icon being changed, system level apps like appstore.app and settings.app fail to change icons.

(Gatekeeper Warning)

When opening the app for the first time, you may see a warning saying: **"Apple could not verify 'IconChanger' is free of malware."**

Because this is a free, open-source application, it is not signed with a paid Apple Developer certificate. macOS automatically flags unsigned applications downloaded from the internet to protect you. 

**How to open the app:**
1. Try to open **Icon Changer** normally (it will be blocked by a warning). Click "OK".
2. Open your Mac's **System Settings**.
3. Navigate to **Privacy & Security**.
4. Scroll down to the **Security** section.
5. You will see a message saying "Icon Changer was blocked from use because it is not from an identified developer." Click the **"Open Anyway"** button next to it. 
*(You only have to do this once! The app will open normally from then on).*

---

## ⚠️ Warning: Electron Apps & Auto-Updaters

While Icon Changer uses native macOS APIs to safely change icons, **some applications (specifically Electron-based apps like VS Code, Discord, Spotify, or Antigravity) may experience issues or revert their icons.**

**Why does this happen?**
Many modern apps use aggressive background auto-updaters (like `Squirrel.Mac`). When you change an app's icon, macOS adds a hidden custom icon file (`Icon\r`) to the app bundle. The background auto-updater performs strict security checks on the app's files, and it flags this custom icon as an unauthorized modification. 

**What happens if the updater flags it?**
- The background update may fail, which can sometimes temporarily break the app or cause it to crash on launch.
- To repair itself, the app will force a fresh download of the entire application.
- This fresh installation overwrites the app bundle, completely removing your custom icon and reverting it to the default.

If you notice an app breaking or losing its custom icon shortly after applying it, this built-in auto-updater behavior is the cause.

---

## Features

- **Drag & Drop Simplicity**: Drop any `.app`, folder, or file into the app, and **drag an image directly from the built-in web browser into the Target box** to instantly change its icon.
- **Native macOS Design**: Built entirely with SwiftUI, featuring translucent sidebars, vibrant materials, and an integrated native web browser.
- **Save Your Favorites**: Configure a custom Download Directory to permanently archive any icons you apply or download.
- **Built-in Icon Browsing**: Browse macOSIcons, Icons8, Flaticon, IconFinder, and DeviantArt directly within the app without needing a separate web browser.

---

## Supported Targets

Because Icon Changer uses native macOS APIs, you can change the icon for virtually **anything** on your Mac:
- **Applications** (`.app`)
- **Folders**
- **Volumes & Hard Drives**
- **Documents & Files** (`.pdf`, `.txt`, `.docx`, `.png`, etc.)
- **Scripts & Executables** (`.sh`, `.py`, etc.)
- **Aliases & Shortcuts**

---

## How to Use

1. **Launch the App:** Open `Icon Changer.app`.
2. **Select Target:** Drag the file or application you want to modify and drop it into the **Target** zone on the left sidebar.
3. **Find an Icon:** Browse the built-in repositories on the right.
4. **Apply:**
   - *Drag & Drop:* Click and drag any image from the web view directly over the Target zone to apply it instantly.
   - *One-Click:* Click the download button on any `.icns` file to have it applied automatically.
5. **Troubleshooting:** If the icon doesn't update in your Dock immediately, click the **Refresh Dock** button in the sidebar.

---

## Credits & Integration

**Lead Developer:** wako69420
I made this application for personal use then realized i can archive and update it here.

This app integrates with the best icon repositories on the web to make customization seamless:
- [**macOSIcons**](https://macosicons.com) - A massive community-driven repository of macOS icons. Thanks to the community and developers.
- [**Icons8**](https://icons8.com) - High-quality design assets and Mac icons.
- [**Flaticon**](https://flaticon.com) - Great repository for minimal folder and UI icons.
- [**IconFinder**](https://iconfinder.com) - Search engine for premium and free icons.
- [**IconArchive**](https://iconarchive.com) - Huge database of app and system icons.

---

## Supported Languages
- English

## Privacy Policy
Please refer to our [Privacy Policy](PRIVACY.md).

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing
Pull requests are welcome! If you'd like to add more icon sources, improve the UI, or add features, feel free to fork this repository and submit a PR.
