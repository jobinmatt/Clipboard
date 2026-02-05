import SwiftUI
import AppKit

@main
struct ClipboardHistoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var limitMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Disable buffering
        setbuf(stdout, nil)
        print("App Started")
        
        // Request accessibility permissions
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let access = AXIsProcessTrustedWithOptions(options as CFDictionary)
        print("Accessibility access: \(access)")
        
        // Initialize Core Components
        ClipboardManager.shared.startMonitoring()
        HotKeyManager.shared.setup()

        // Setup Floating Panel
        WindowManager.shared.setup()
        
        // Setup Status Bar
        setupStatusBar()
    }
    
    func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            // Use a paperclip or a doc icon
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard History")
        }
        
        let menu = NSMenu()
        
        // Clear Action
        menu.addItem(withTitle: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
        
        // Limit Submenu
        let limitMenu = NSMenu()
        let currentLimit = ClipboardManager.shared.limit
        limitMenuItem = NSMenuItem(title: "History Limit (\(currentLimit))", action: nil, keyEquivalent: "")
        limitMenuItem.submenu = limitMenu
        menu.addItem(limitMenuItem)
        
        for l in [50, 100, 200, 500] {
            let item = NSMenuItem(title: "\(l)", action: #selector(setLimit(_:)), keyEquivalent: "")
            item.tag = l
            item.state = (l == currentLimit) ? .on : .off
            limitMenu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let startAtLoginItem = NSMenuItem(title: "Start at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        startAtLoginItem.state = checkLaunchAtLoginState() ? .on : .off
        menu.addItem(startAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        
        statusBarItem.menu = menu
    }
    
    @objc func clearHistory() {
        ClipboardManager.shared.clearHistory()
        print("History Cleared")
    }
    
    @objc func setLimit(_ sender: NSMenuItem) {
        let newLimit = sender.tag
        ClipboardManager.shared.setLimit(newLimit)
        
        // Update Title
        if let limitMenuItem = limitMenuItem {
            limitMenuItem.title = "History Limit (\(newLimit))"
        }
        
        // Update Checkmarks
        if let submenu = limitMenuItem?.submenu {
            for item in submenu.items {
                item.state = (item.tag == newLimit) ? .on : .off
            }
        }
        
        print("Limit set to \(newLimit)")
    }
    
    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        let launchAgentURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.local.ClipboardHistory.plist")
        
        if FileManager.default.fileExists(atPath: launchAgentURL.path) {
            try? FileManager.default.removeItem(at: launchAgentURL)
            sender.state = .off
            print("Removed LaunchAgent")
        } else {
            // Create Plist
            // Use executablePath to be precise (works for both binary and .app)
            guard let path = Bundle.main.executablePath else { return }
            
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.local.ClipboardHistory</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(path)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
                <key>KeepAlive</key>
                <false/>
                <key>ProcessType</key>
                <string>Interactive</string>
            </dict>
            </plist>
            """
            
            do {
                // Ensure directory exists
                let directoryURL = launchAgentURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                try plistContent.write(to: launchAgentURL, atomically: true, encoding: .utf8)
                sender.state = .on
                print("Created LaunchAgent at \(launchAgentURL.path)")
            } catch {
                print("Failed to create LaunchAgent: \(error)")
            }
        }
    }
    
    func checkLaunchAtLoginState() -> Bool {
        let launchAgentURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.local.ClipboardHistory.plist")
        return FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
