import SwiftUI
import AppKit

struct HistoryView: View {
    @ObservedObject var clipboardManager = ClipboardManager.shared
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                Spacer()
                if !clipboardManager.history.isEmpty {
                    Button(action: {
                        clipboardManager.clearHistory()
                    }) {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
            
            if clipboardManager.history.isEmpty {
                // Empty State
                VStack(spacing: 15) {
                    Spacer()
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No History")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(clipboardManager.history.enumerated()), id: \.element.id) { index, item in
                                VStack(spacing: 0) {
                                    HistoryItemRow(
                                        item: item, 
                                        isSelected: index == selectedIndex,
                                        onDelete: {
                                            clipboardManager.removeItem(item)
                                        }
                                    )
                                    .simultaneousGesture(TapGesture().onEnded {
                                        selectedIndex = index
                                        pasteSelected()
                                    })
                                    .id(index)
                                    
                                    // Separator
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                }
                            }
                        }
                    }
                    .onChange(of: selectedIndex) { oldValue, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .onAppear {
            selectedIndex = 0
        }
    }
    
    private func pasteSelected() {
        guard clipboardManager.history.indices.contains(selectedIndex) else { return }
        let item = clipboardManager.history[selectedIndex]
        PasteManager.shared.paste(item: item)
    }
}

struct HistoryItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onDelete: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            if item.type == .image, let nsImage = item.image {
                // Image Preview
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 80) // Limit height
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let text = item.text {
                // Text Preview
                Text(text)
                    .lineLimit(6) // Allow more lines
                    .font(.system(size: 13)) // Slightly smaller font for density
                    .truncationMode(.tail)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 12)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .background(isSelected ? Color.accentColor.opacity(0.3) : (isHovering ? Color.secondary.opacity(0.1) : Color.clear))
        .contentShape(Rectangle()) // Make full row clickable
        .onHover { inside in
            isHovering = inside
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
