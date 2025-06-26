import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.clipboard.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 48))
            
            VStack(spacing: 8) {
                Text("Clipboard Manager")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Press ⌥⌘V to view clipboard history")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current clipboard items: \(SharedClipboardManager.shared.history.count)")
                    .font(.caption)
                
                if let latest = SharedClipboardManager.shared.history.first {
                    Text("Latest: \(latest.prefix(50))...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .onReceive(SharedClipboardManager.shared.$history) { _ in }
    }
}

#Preview {
    ContentView()
}
