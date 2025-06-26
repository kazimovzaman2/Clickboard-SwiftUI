
import Cocoa
import Carbon

func fourCharCode(_ code: String) -> OSType {
    var result: UInt32 = 0
    for char in code.utf8 {
        result = (result << 8) + UInt32(char)
    }
    return result
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var eventHotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHotKey()
    }
    
    func registerHotKey() {
        let hotKeyID = EventHotKeyID(signature: fourCharCode("CLPB"), id: 1)
        let modifierKeys: UInt32 = UInt32(cmdKey | optionKey)
        let keyCode: UInt32 = 9 // 'V' key
        
        let status = RegisterEventHotKey(keyCode, modifierKeys, hotKeyID, GetApplicationEventTarget(), 0, &eventHotKeyRef)
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        }
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, event, userData) -> OSStatus in
            var hkCom = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hkCom)
            
            if hkCom.id == 1 {
                print("Hotkey pressed - toggling clipboard window")
                NotificationCenter.default.post(name: Notification.Name("ToggleClipboardWindow"), object: nil)
            }
            
            return noErr
        }, 1, &eventType, nil, nil)
    }
}
