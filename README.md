# MacClipboardHistory

A lightweight, native macOS clipboard history manager built with Swift and SwiftUI.

## Features
- **Clipboard History**: Tracks text and images copied to your clipboard.
- **Global Hotkey**: Press `Cmd+Shift+V` to open the history anywhere.
- **Floating Window**: Appears near your cursor for quick access.
- **Image Previews**: Shows previews of copied images.
- **Auto-Hide**: Disappears automatically when you switch apps or click outside.
- **Click to Paste**: Clicking an entry automatically pastes it into your active application.

## Installation / Build

### Prerequisites
- macOS (tested on macOS 14.0+)
- Swift installed (comes with Xcode Command Line Tools)

### Build
Run the following command in the terminal to build the app:
```bash
make app
```
This will create `ClipboardHistory.app` in the project directory.

### Usage
1. Open `ClipboardHistory.app`.
2. Grant **Accessibility Permissions** when prompted (required for global hotkeys and pasting).
3. Copy some text or images.
4. Press `Cmd+Shift+V` to see your history.

**Important Note on Rebuilding:**
Since `make app` signs the bundle with an ad-hoc signature, macOS generates a new cryptographic hash every time you build it. If you ever rebuild the app and replace the copy in your `/Applications` folder, **macOS will silently revoke its Accessibility permissions**. 
If pasting stops working, you must:
1. Open **System Settings > Privacy & Security > Accessibility**
2. Remove the old `ClipboardHistory` entry using the `-` button.
3. Add the newly built app back using the `+` button.

## Development
To run in debug mode (logs to file):
```bash
make build && ./ClipboardHistory
```
