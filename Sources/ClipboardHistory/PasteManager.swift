import Cocoa

class PasteManager {
    static let shared = PasteManager()
    
    func paste(item: ClipboardItem) {
        // 1. Hide the window/app to return focus to the previous app
        WindowManager.shared.closeWindow()
        WindowManager.shared.activateLastApplication()
        
        // 2. Put content on clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            if let text = item.text {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = item.image {
                pasteboard.writeObjects([image])
            }
        }
        
        // 3. Sync clipboard manager to avoid duplicate entry
        ClipboardManager.shared.updateLastChangeCount()
        
        // 4. Wait a bit for focus to switch back and clipboard to update
        // Reduced delay for better responsiveness now that we explicitly activate the app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.simulatePasteCommand()
        }
    }
    
    private func simulatePasteCommand() {
        // Simulate Cmd+V
        
        let vKeyCode: CGKeyCode = 0x09 // kVK_ANSI_V
        
        // .combinedSessionState works better for user session events
        guard let source = CGEventSource(stateID: .combinedSessionState) else {
            print("Failed to create CGEventSource")
            return
        }
        
        // CMD down
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        cmdDown?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        
        // V down
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        
        // V up
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
        vUp?.flags = .maskCommand
        vUp?.post(tap: .cghidEventTap)
        
        // CMD up
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        cmdUp?.flags = [] // Clear flags
        cmdUp?.post(tap: .cghidEventTap)
        
        print("Paste Command Sent")
    }
}
