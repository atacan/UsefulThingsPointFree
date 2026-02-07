#if canImport(SwiftUI)
  import SwiftUI
  import Dependencies

  extension DependencyValues {
    /// A dependency that opens a URL.
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
      public var openWindow: OpenWindowEffect {
      get { self[OpenWindowKey.self] }
      set { self[OpenWindowKey.self] = newValue }
    }
  }

  @available(iOS 16, macOS 13, tvOS 14, watchOS 7, *)
  private enum OpenWindowKey: DependencyKey {
    static let liveValue = OpenWindowEffect { id in
        EnvironmentValues().openWindow(id: id)
    }
    static let testValue = OpenWindowEffect { id in
        XCTFail(#"Unimplemented: @Dependency(\.openWindow) id: \#(id)"#)
    }
  }

  public struct OpenWindowEffect: Sendable {
      private let handler: @Sendable (_ id: String) -> Void

    public init(handler: @escaping @Sendable (String) -> Void) {
      self.handler = handler
    }

      public func callAsFunction(id: String) -> Void {
          self.handler(id)
    }
  }
#endif
