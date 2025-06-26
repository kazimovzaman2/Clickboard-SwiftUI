
import Foundation
import AppKit

// Shared clipboard manager instance
class SharedClipboardManager: ObservableObject {
    static let shared = SharedClipboardManager()
    
    @Published var history: [String] = []
    private var changeCount: Int
    private var timer: Timer?
    
    private init() {
        self.changeCount = NSPasteboard.general.changeCount
        startPolling()
        // Check for existing clipboard content on startup
        checkClipboard()
    }
    
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            
            if let newString = pasteboard.string(forType: .string),
               !newString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               history.first != newString {
                
                DispatchQueue.main.async {
                    self.history.insert(newString, at: 0)
                    if self.history.count > 50 {
                        self.history.removeLast()
                    }
                    print("Added clipboard item: \(newString.prefix(50))...")
                    
                    // Update menu bar menu
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        appDelegate.setupMenu()
                    }
                }
            }
        }
    }
    
    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        // Update our change count to avoid re-adding this item
        changeCount = NSPasteboard.general.changeCount
    }
    
    func clearHistory() {
        DispatchQueue.main.async {
            self.history.removeAll()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
