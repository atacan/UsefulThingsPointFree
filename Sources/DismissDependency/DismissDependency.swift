#if canImport(SwiftUI)
import SwiftUI
import Dependencies

extension DependencyValues {
    /// A dependency that opens a URL.
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
    public var environmentDismiss: DismissEffect {
        get { self[DismissKey.self] }
        set { self[DismissKey.self] = newValue }
    }
}

@available(iOS 16, macOS 13, tvOS 14, watchOS 7, *)
private enum DismissKey: DependencyKey {
    static let liveValue = DismissEffect {
        EnvironmentValues().dismiss()
    }
    static let testValue = DismissEffect {
        XCTFail(#"Unimplemented: @Dependency(\.dismiss)"#)
    }
}

public struct DismissEffect: Sendable {
    private let handler: @Sendable () -> Void
    
    public init(handler: @escaping @Sendable () -> Void) {
        self.handler = handler
    }
    
    public func callAsFunction() -> Void {
        self.handler()
    }
}
#endif
