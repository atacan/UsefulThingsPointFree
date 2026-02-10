#if canImport(SwiftUI)
  import SwiftUI
  import StoreKit
  import Dependencies

  extension DependencyValues {
    /// A dependency that opens a URL.
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
    public var requestReview: RequestReviewEffect {
      get { self[RequestReviewKey.self] }
      set { self[RequestReviewKey.self] = newValue }
    }
  }

  @available(iOS 16, macOS 13, tvOS 14, watchOS 7, *)
  private enum RequestReviewKey: DependencyKey {
    static let liveValue = RequestReviewEffect {
        await EnvironmentValues().requestReview()
    }
    static let testValue = RequestReviewEffect {
      XCTFail(#"Unimplemented: @Dependency(\.requestReview)"#)
    }
  }

  public struct RequestReviewEffect: Sendable {
    private let handler: @Sendable () async -> Void

    public init(handler: @escaping @Sendable () async -> Void) {
      self.handler = handler
    }

    public func callAsFunction() async -> Void {
      await self.handler()
    }
  }
#endif
