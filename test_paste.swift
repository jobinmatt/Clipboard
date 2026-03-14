import Cocoa

let text = "Hello from test script"
let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(text, forType: .string)

let source = CGEventSource(stateID: .hidSystemState)
let cmdKey: CGKeyCode = 0x37
let vKey: CGKeyCode = 0x09

let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true)
let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true)
vDown?.flags = .maskCommand
let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false)
vUp?.flags = .maskCommand
let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false)

cmdDown?.post(tap: .cghidEventTap)
vDown?.post(tap: .cghidEventTap)
vUp?.post(tap: .cghidEventTap)
cmdUp?.post(tap: .cghidEventTap)

print("Test script finished")
