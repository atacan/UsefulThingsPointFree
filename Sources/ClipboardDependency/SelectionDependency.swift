#if os(macOS)

import ApplicationServices
import Cocoa

import Dependencies

public struct GetSelectionClient {
    public var text: () -> String?
    public var textByPressingCopyShortcut: () async -> String?
}

extension GetSelectionClient: DependencyKey {
    public static var liveValue: Self {
        Self(
            text: {
                getSelectedText()
            },
            textByPressingCopyShortcut: {
                await getSelectedStringByPressingCopyShortcut()
            }
        )
    }
}

extension DependencyValues {
    public var getSelection: GetSelectionClient {
        get { self[GetSelectionClient.self] }
        set { self[GetSelectionClient.self] = newValue }
    }
}


/// This requires setting `Privacy - AppleEvents Sending Usage Description` in Info.plist
/// and setting `com.apple.security.temporary-exception.apple-events` to have `com.apple.systemevents`.
/// https://stackoverflow.com/questions/76009610/get-selected-text-when-in-any-application-on-macos
///
func getSelectedText() -> String? {
    let systemWideElement = AXUIElementCreateSystemWide()
    
    var selectedTextValue: AnyObject?
    let errorCode = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &selectedTextValue)
    
    if errorCode == .success {
        let selectedTextElement = selectedTextValue as! AXUIElement
        var selectedText: AnyObject?
        let textErrorCode = AXUIElementCopyAttributeValue(selectedTextElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textErrorCode == .success, let selectedTextString = selectedText as? String {
            return selectedTextString
        } else {
            return nil
        }
    } else {
        return nil
    }
}

/// https://stackoverflow.com/questions/6544311/how-to-get-global-screen-coordinates-of-currently-selected-text-via-accessibilit
///
func selectionRect() {
    let systemWideElement = AXUIElementCreateSystemWide()
    var focusedElement : AnyObject?
    
    let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
    if (error != .success){
        print("Couldn't get the focused element. Probably a webkit application")
    } else {
        var selectedRangeValue : AnyObject?
        let selectedRangeError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
        if (selectedRangeError == .success){
            var selectedRange : CFRange?
            AXValueGetValue(selectedRangeValue as! AXValue, AXValueType(rawValue: kAXValueCFRangeType)!, &selectedRange)
            var selectRect = CGRect()
            var selectBounds : AnyObject?
            let selectedBoundsError = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, selectedRangeValue!, &selectBounds)
            if (selectedBoundsError == .success){
                AXValueGetValue(selectBounds as! AXValue, .cgRect, &selectRect)
                //do whatever you want with your selectRect
                print(selectRect)
            }
        }
    }
}

private func pressCopy() {
    let commandV = CGEvent(keyboardEventSource: nil, virtualKey: 0x08, keyDown: true)  // 0x08 is the virtual key for 'c'
    commandV?.flags = .maskCommand
    commandV?.post(tap: .cghidEventTap)
    
    let commandVUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x08, keyDown: false)
    commandVUp?.flags = .maskCommand
    commandVUp?.post(tap: .cghidEventTap)
}

func readFromPasteboard() -> [NSPasteboardItem] {
    var pasteboardItems = [NSPasteboardItem]()
    for item in NSPasteboard.general.pasteboardItems! {
        let dataHolder = NSPasteboardItem()
        for type in item.types {
            if let data = item.data(forType: type) {
                dataHolder.setData(data, forType: type)
            }
        }
        pasteboardItems.append(dataHolder)
    }
    return pasteboardItems
}

func getSelectedStringByPressingCopyShortcut() async -> String? {
    // backup Clipboard
    let pasteboard = NSPasteboard.general
    let savedItems = readFromPasteboard()
    // Copy
    pressCopy()
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
    
    let newItems = readFromPasteboard()
    guard let newItem = newItems.first?.string(forType: .string),
          !savedItems.contains(where: { $0.string(forType: .string) == newItem })
    else { return nil }
    
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
    // restore Clipboard
    pasteboard.clearContents()
    pasteboard.writeObjects(savedItems)
        
    return newItem
}
#endif
