import Cocoa
import SwiftUI

class WindowManager: NSObject {
    static let shared = WindowManager()
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?

    var panel: NSPanel?
    var lastActiveApplication: NSRunningApplication?
    
    func setup() {
        // ... (existing setup code) ...
        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.nonactivatingPanel, .borderless, .resizable], 
            backing: .buffered,
            defer: false
        )
        
        newPanel.level = .floating
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = true
        newPanel.isMovableByWindowBackground = true 
        
        // Host SwiftUI content
        let contentView = HistoryView()
        newPanel.contentView = NSHostingView(rootView: contentView)
        
        self.panel = newPanel
        
        // Manual auto-hide on app switching
        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
             self?.closeWindow()
        }
    }
    
    func toggleWindow() {
        if panel?.isVisible == true {
            closeWindow()
        } else {
            showWindowNearCursor()
        }
    }
    
    func closeWindow() {
        panel?.orderOut(nil)
        
        // Remove monitors
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        if let monitor = localClickMonitor {
            NSEvent.removeMonitor(monitor)
            localClickMonitor = nil
        }
    }
    
    func activateLastApplication() {
        if let lastApp = lastActiveApplication {
            print("Activating previous app: \(lastApp.localizedName ?? "Unknown")")
            // activateIgnoringOtherApps is deprecated in macOS 14
            lastApp.activate(options: [.activateAllWindows])
            lastActiveApplication = nil
        } else {
             print("No previous app found. Hiding self.")
             // Fallback: Just hide our app
             NSApp.hide(nil)
        }
    }
    
    private func showWindowNearCursor() {
        guard let panel = panel else { return }
        let mouseLocation = NSEvent.mouseLocation
        
        // ... (Screen clamping logic) ...
        // Get the screen where the mouse is
        var screen: NSScreen?
        for s in NSScreen.screens {
            if NSMouseInRect(mouseLocation, s.frame, false) {
                screen = s
                break
            }
        }
        let currentScreen = screen ?? NSScreen.main ?? NSScreen.screens[0]
        
        var frame = panel.frame
        let screenFrame = currentScreen.visibleFrame
        
        // Initial Position
        var newOriginX = mouseLocation.x
        var newOriginY = mouseLocation.y - frame.height
        
        // Clamp Horizontal
        if newOriginX + frame.width > screenFrame.maxX {
            newOriginX = screenFrame.maxX - frame.width - 10
        }
        if newOriginX < screenFrame.minX {
            newOriginX = screenFrame.minX + 10
        }
        
        // Clamp Vertical
        if newOriginY < screenFrame.minY {
            newOriginY = mouseLocation.y + 10
        }
        
        frame.origin = CGPoint(x: newOriginX, y: newOriginY)
        
        print("Showing window at: \(frame)")
        
        panel.setFrame(frame, display: true)
        panel.makeKeyAndOrderFront(nil)
        
        // Capture the previous app before taking focus
        lastActiveApplication = NSWorkspace.shared.frontmostApplication
        
        NSApp.activate(ignoringOtherApps: true)
        
        // Setup click monitors
        setupClickMonitors()
    }
    
    private func setupClickMonitors() {
        // Global monitor for clicks outside the app
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            // Must dispatch async to avoid removing monitor while handling it
            DispatchQueue.main.async {
                self?.closeWindow()
            }
        }
        
        // Local monitor for clicks inside the app
        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let panel = self.panel else { return event }
            if panel.isVisible {
                let locationInWindow = event.locationInWindow
                if let contentView = panel.contentView, !contentView.bounds.contains(locationInWindow) {
                     // Async close
                     DispatchQueue.main.async {
                         self.closeWindow()
                     }
                     return nil 
                }
            }
            return event
        }
    }
}
