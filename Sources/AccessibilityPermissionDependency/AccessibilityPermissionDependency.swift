#if canImport(Cocoa)
import Cocoa

import Dependencies

public
struct AccessibilityPermissionDependency {
    public var checkIsProcessTrusted: () -> Bool
}

extension AccessibilityPermissionDependency: DependencyKey {
    public static var liveValue: Self = Self(
        checkIsProcessTrusted: {
            let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
            let options: CFDictionary = [checkOptionPrompt: true] as CFDictionary
            let result = AXIsProcessTrustedWithOptions(options)
            
            return result
        }
    )
    
    public static var previewValue: Self = Self(
        checkIsProcessTrusted: {
            return true
        }
    )
}

extension DependencyValues {
    public var accessibilityPermission: AccessibilityPermissionDependency {
        get { self[AccessibilityPermissionDependency.self] }
        set { self[AccessibilityPermissionDependency.self] = newValue }
      }
}
#endif
