import Cocoa

class PasteManager {
    static let shared = PasteManager()
    
    func paste(item: ClipboardItem) {
        // 1. Put content on clipboard
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
        
        // 2. Sync clipboard manager to avoid duplicate entry
        ClipboardManager.shared.updateLastChangeCount()
        
        // 3. Hide the window AND the application to ensure focus returns to target app
        WindowManager.shared.closeWindow()
        WindowManager.shared.activateLastApplication()
        
        // 4. Paste immediately (with a slightly larger buffer for focus change)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.simulatePasteCommand()
        }
    }
    
    private func simulatePasteCommand() {
        print("Executing Paste Simulation...")
        
        let vKey: CGKeyCode = 0x09 // kVK_ANSI_V
        if let source = CGEventSource(stateID: .hidSystemState) {
            let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true)
            vDown?.flags = .maskCommand
            
            let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false)
            vUp?.flags = .maskCommand
            
            vDown?.post(tap: .cghidEventTap)
            vUp?.post(tap: .cghidEventTap)
            print("Paste events delivered.")
        } else {
            print("Failed to create event source.")
        }
    }
}
