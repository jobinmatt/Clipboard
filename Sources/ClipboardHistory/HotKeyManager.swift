import Cocoa
import Carbon

class HotKeyManager {
    static let shared = HotKeyManager()
    
    private var hotKeyRef: EventHotKeyRef?
    
    func setup() {
        // defined in <Carbon/Carbon.h>
        // kVK_ANSI_V = 0x09
        let vKeyCode: UInt32 = 0x09
        
        // Register Fn+V
        // Modifiers: cmdKey, shiftKey, optionKey, controlKey
        // For Fn key, it's a bit special but typically we rely on standard modifiers.
        // User asked for Fn+V. "Fn" is kEventKeyModifierFnMask (not always available in simple bitmask).
        // Let's stick to Cmd+Shift+V as agreed for better reliability first
        
        let modifiers = cmdKey | shiftKey
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("cbhs".asUInt32) // "cbhs" = clipboard history
        hotKeyID.id = 1
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        // Install handler
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            // Check if it is our hotkey
            var hkCom: EventHotKeyID = EventHotKeyID()
            GetEventParameter(theEvent,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hkCom)
            
            if hkCom.id == 1 {
                DispatchQueue.main.async {
                    print("Carbon HotKey Pressed!")
                    WindowManager.shared.toggleWindow()
                }
                return noErr
            }
            
            return CallNextEventHandler(nextHandler, theEvent)
        }, 1, &eventType, nil, nil)
        
        // Register the hotkey
        let status = RegisterEventHotKey(vKeyCode,
                                         UInt32(modifiers),
                                         hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        
        print("RegisterEventHotKey status: \(status)")
    }
}

// Helper extension for OSType
extension String {
    var asUInt32: UInt32 {
        var result: UInt32 = 0
        for char in self.utf8 {
            result = (result << 8) | UInt32(char)
        }
        return result
    }
}
