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
        
        // 3. Hide the window
        WindowManager.shared.closeWindow()
        
        // 4. Paste immediately (with a tiny buffer to ensure click event finishes)
        // Since we are non-activating, focus never left the target app!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePasteCommand()
        }
    }
    
    private func simulatePasteCommand() {
        print("Executing Paste Simulation...")
        
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdKey: CGKeyCode = 0x37
        let vKey: CGKeyCode = 0x09
        
        // 1. Command Down
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true)
        
        // 2. V Down (with Command Flag)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true)
        vDown?.flags = .maskCommand
        
        // 3. V Up (with Command Flag)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false)
        vUp?.flags = .maskCommand
        
        // 4. Command Up
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false)
        
        // Post events to the HID tap (hardware level)
        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
        
        print("Paste events delivered.")
    }
}
