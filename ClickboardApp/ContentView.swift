
import SwiftUI

// This view is not used in menu bar mode, but keeping it for reference
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
                
                Text("Running in menu bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
