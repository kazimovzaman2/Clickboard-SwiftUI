import Cocoa
import Carbon
import SwiftUI

func fourCharCode(_ code: String) -> OSType {
    var result: UInt32 = 0
    for char in code.utf8 {
        result = (result << 8) + UInt32(char)
    }
    return result
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var eventHotKeyRef: EventHotKeyRef?
    var statusItem: NSStatusItem?
    var clipboardWindow: NSWindow?
    var eventHandler: EventHandlerRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        registerHotKey()
        
        // Start clipboard monitoring
        _ = SharedClipboardManager.shared
        
        print("Application finished launching - hotkey should be registered")
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(toggleClipboardWindow)
            button.target = self
        }
        
        setupMenu()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Show Clipboard History", action: #selector(showClipboardWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Add recent clipboard items to menu
        let recentItems = SharedClipboardManager.shared.history.prefix(5)
        if !recentItems.isEmpty {
            for (index, item) in recentItems.enumerated() {
                let truncatedItem = String(item.prefix(50)) + (item.count > 50 ? "..." : "")
                let menuItem = NSMenuItem(title: "\(index + 1). \(truncatedItem)", action: #selector(copyFromMenu(_:)), keyEquivalent: "")
                menuItem.tag = index
                menuItem.target = self
                menu.addItem(menuItem)
            }
            menu.addItem(NSMenuItem.separator())
        }
        
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleClipboardWindow() {
        print("Toggle clipboard window called")
        if clipboardWindow?.isVisible == true {
            hideClipboardWindow()
        } else {
            showClipboardWindow()
        }
    }
    
    @objc func showClipboardWindow() {
        print("Show clipboard window called")
        if clipboardWindow == nil {
            createClipboardWindow()
        }
        
        clipboardWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideClipboardWindow() {
        print("Hide clipboard window called")
        clipboardWindow?.orderOut(nil)
    }
    
    func createClipboardWindow() {
        let contentView = ClipboardView(onClose: { [weak self] in
            self?.hideClipboardWindow()
        })
        
        clipboardWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        clipboardWindow?.title = "Clipboard History"
        clipboardWindow?.contentView = NSHostingView(rootView: contentView)
        clipboardWindow?.center()
        clipboardWindow?.isReleasedWhenClosed = false
        
        // Set window level to float above other windows
        clipboardWindow?.level = .floating
    }
    
    @objc func copyFromMenu(_ sender: NSMenuItem) {
        let index = sender.tag
        if index < SharedClipboardManager.shared.history.count {
            let item = SharedClipboardManager.shared.history[index]
            SharedClipboardManager.shared.copyToClipboard(item)
        }
    }
    
    @objc func clearHistory() {
        SharedClipboardManager.shared.clearHistory()
        setupMenu()
    }
    
    func registerHotKey() {
        print("Setting up modern hotkey monitoring...")
            
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .option]) &&
               event.keyCode == 9 {
                print("Modern hotkey detected!")
                DispatchQueue.main.async {
                    self?.toggleClipboardWindow()
                }
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .option]) &&
               event.keyCode == 9 {
                print("Local modern hotkey detected!")
                DispatchQueue.main.async {
                    self?.toggleClipboardWindow()
                }
                return nil
            }
            return event
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("Application terminating - cleaning up...")
        
        if let eventHotKeyRef = eventHotKeyRef {
            UnregisterEventHotKey(eventHotKeyRef)
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
