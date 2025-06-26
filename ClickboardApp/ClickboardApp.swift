
import SwiftUI

@main
struct ClickboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showClipboardWindow = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400, height: 300)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ToggleClipboardWindow"))) { _ in
                    print("Received toggle notification")
                    showClipboardWindow.toggle()
                }
                .sheet(isPresented: $showClipboardWindow) {
                    ClipboardView()
                        .frame(minWidth: 500, minHeight: 600)
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
