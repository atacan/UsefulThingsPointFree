import Dependencies
import DependenciesMacros
import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "DownloadFileClient")

@DependencyClient
public struct DownloadFileClient {
    public var download: @Sendable (_ url: URL, _ destination: URL) async throws -> AsyncThrowingStream<DownloadFileResult, Error> = { _,_  in .finished() }
}

extension DependencyValues {
    public var downloadFileClient: DownloadFileClient {
        get { self[DownloadFileClient.self] }
        set { self[DownloadFileClient.self] = newValue }
    }
}

extension DownloadFileClient: DependencyKey {
    public static var liveValue: Self {
        
        return Self(
            download: { url, destination in
                let downloader = DownloadFile(url: url)
                return try await downloader.startDownloading(to: destination)
            }
        )
    }
    
    public static let testValue = Self()
    
    public static var previewValue = Self(
        download: {_,_ in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            
            return AsyncThrowingStream<DownloadFileResult, Error> { continuation in
                continuation.yield(.didFinishDownloadingTo(URL(string: NSHomeDirectory())!))
                continuation.finish()
            }
        }
    )
}
