#if canImport(SwiftUI)
  import SwiftUI
  import Dependencies

  extension DependencyValues {
    /// A dependency that opens a URL.
    @available(iOS 17, macOS 14, tvOS 14, watchOS 7, *)
      public var dismissWindow: DismissWindowEffect {
      get { self[DismissWindowKey.self] }
      set { self[DismissWindowKey.self] = newValue }
    }
  }

  @available(iOS 17, macOS 14, tvOS 14, watchOS 7, *)
  private enum DismissWindowKey: DependencyKey {
      static let liveValue = DismissWindowEffect { id in
        EnvironmentValues().dismissWindow(id: id)
    }
    static let testValue = DismissWindowEffect { id in
        XCTFail(#"Unimplemented: @Dependency(\.dismissWindow) id: \#(id)"#)
    }
  }

  public struct DismissWindowEffect: Sendable {
      private let handler: @Sendable @MainActor (_ id: String) -> Void

    public init(handler: @escaping @Sendable @MainActor (String) -> Void) {
      self.handler = handler
    }

      @MainActor
      public func callAsFunction(id: String) {
          self.handler(id)
    }
  }
#endif
