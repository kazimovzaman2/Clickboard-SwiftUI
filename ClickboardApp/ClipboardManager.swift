import Foundation
import AppKit

class SharedClipboardManager: ObservableObject {
    static let shared = SharedClipboardManager()
    
    @Published var history: [String] = []
    private var changeCount: Int
    private var timer: Timer?
    
    private init() {
        self.changeCount = NSPasteboard.general.changeCount
        startPolling()
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
                }
            }
        }
    }
    
    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        changeCount = NSPasteboard.general.changeCount
    }
    
    deinit {
        timer?.invalidate()
    }
}
