
import SwiftUI

struct ClipboardView: View {
    @ObservedObject var clipboardManager = SharedClipboardManager.shared
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Clipboard History")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(clipboardManager.history.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Close") {
                    onClose()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Clipboard items list
            if clipboardManager.history.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No clipboard history yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Copy something to see it here")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(Array(clipboardManager.history.enumerated()), id: \.offset) { index, item in
                        ClipboardItemView(
                            item: item,
                            index: index,
                            onCopy: {
                                clipboardManager.copyToClipboard(item)
                                onClose()
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            // Footer with shortcuts
            HStack {
                Text("⌥⌘V to toggle • Click item to copy • ESC to close")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Spacer()
                Button("Clear All") {
                    clipboardManager.clearHistory()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(minWidth: 500, minHeight: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            print("ClipboardView appeared with \(clipboardManager.history.count) items")
        }
    }
}

struct ClipboardItemView: View {
    let item: String
    let index: Int
    let onCopy: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(index + 1)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item)
                        .lineLimit(3)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                    
                    Text("\(item.count) characters")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if isHovered {
                    Button("Copy") {
                        onCopy()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onCopy()
        }
    }
}
