import Cocoa
import Combine

enum ClipboardType {
    case text
    case image
}

struct ClipboardItem: Identifiable, Hashable {
    let id = UUID()
    let type: ClipboardType
    let text: String?
    let image: NSImage?
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var history: [ClipboardItem] = []
    @Published var limit: Int = 200
    
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    
    func startMonitoring() {
        // Initial check
        checkClipboard()
        
        // Faster polling for responsiveness
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func clearHistory() {
        history.removeAll()
    }
    
    func setLimit(_ newLimit: Int) {
        limit = newLimit
        if history.count > limit {
            history.removeLast(history.count - limit)
        }
    }
    
    func removeItem(_ item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: index)
        }
    }
    
    func updateLastChangeCount() {
        lastChangeCount = NSPasteboard.general.changeCount
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            var newItem: ClipboardItem?
            
            // Check for Images
            if pasteboard.canReadObject(forClasses: [NSImage.self], options: nil),
               let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
               let firstImage = images.first {
                
                newItem = ClipboardItem(type: .image, text: nil, image: firstImage, date: Date())
                
            } else if let newString = pasteboard.string(forType: .string) {
                // Check for Text
                if let last = history.first, last.type == .text, last.text == newString {
                    return 
                }
                
                newItem = ClipboardItem(type: .text, text: newString, image: nil, date: Date())
            }
            
            if let item = newItem {
                DispatchQueue.main.async {
                    self.history.insert(item, at: 0)
                    // Limit history
                    if self.history.count > self.limit {
                        self.history.removeLast()
                    }
                }
            }
        }
    }
}
