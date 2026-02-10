import Dependencies
import UsefulThings
import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "DownloadFile")

final actor DownloadFile {
    var url: URL
//    var downloadTask: URLSessionDownloadTask?
//    var delegate: DownloadFileDelegate?

    init(url: URL) {
        self.url = url
    }

    func startDownloading(to destination: URL) async throws -> AsyncThrowingStream<DownloadFileResult, Error> {
        guard await remoteFileExists(at: url) else {
            throw ErrorDownloadFile.remoteFileDoesntExist
        }
        
        let lastReportedProgress = LockIsolated(Float(0.0))
        @Sendable func updateProgress(progress: Float) -> Bool {
            let threshold = floor(progress * 10) / 10
            if threshold > lastReportedProgress.value {
                lastReportedProgress.withValue {$0 = threshold}
                return true
            }
            return false
        }

        let stream = AsyncThrowingStream<DownloadFileResult, Error> { continuation in
            let delegate = DownloadFileDelegate(
                didWriteData: { progress in
                    // logger.debug("didWriteData progress: \(progress)")
                    if updateProgress(progress: progress) {
                        continuation.yield(.progress(progress))
                    }
                },
                didFinishDownloadingTo: { url in
                    do {
                        continuation.yield(.didFinishDownloadingTo(url))

                        logger.debug("didFinishDownloadingTo \(url)")
                        
                        try FileManager.default.moveItem(at: url, to: destination)
                        logger.debug("did move file to \(destination)")
                        
                        continuation.finish()
                    } catch {
                        logger.error("moveItem \(error.localizedDescription)")
                        continuation.finish(throwing: error)
                    }
                },
                didCompleteWithError: { error in
                    logger.error("URLSession error \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            )

            let configuration = URLSessionConfiguration.default
            // Optionally, also set the resource timeout (for the entire download)
            configuration.timeoutIntervalForResource = 3600 // 1 hour, adjust as needed
            // Set the timeout interval for the request to 10 minutes (600 seconds)
            configuration.timeoutIntervalForRequest = 600
            configuration.waitsForConnectivity = true

            // Create the URLSession with the custom configuration
            let urlSession = URLSession(
                configuration: configuration,
                delegate: delegate,
                delegateQueue: nil
            )
            let downloadTask = urlSession.downloadTask(with: url)

            downloadTask.resume()

            continuation.onTermination = { _ in
                logger.debug("startDownloading continuation.onTermination")
                downloadTask.cancel()
                urlSession.invalidateAndCancel()
            }
        }

        return stream
    }

//    func finishTask() {
//        downloadTask?.cancel()
//    }
}

public enum DownloadFileResult: Sendable, Equatable {
    case progress(Float)
    case didFinishDownloadingTo(URL)
    case didCompleteWithError(EquatableError)
}

class DownloadFileDelegate: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    let didWriteData: @Sendable (Float) -> Void
    let didFinishDownloadingTo: @Sendable (URL) -> Void
    let didCompleteWithError: @Sendable (Error) -> Void

    init(
        didWriteData: @escaping @Sendable (Float) -> Void,
        didFinishDownloadingTo: @escaping @Sendable (URL) -> Void,
        didCompleteWithError: @escaping @Sendable (Error) -> Void
    ) {
        self.didWriteData = didWriteData
        self.didFinishDownloadingTo = didFinishDownloadingTo
        self.didCompleteWithError = didCompleteWithError
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        didWriteData(calculatedProgress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        didFinishDownloadingTo(location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            didCompleteWithError(error)
        }
    }
}

func fileExists(at url: URL) async throws -> Bool {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    request.timeoutInterval = 1.0 // Adjust to your needs
    let (_, response) = try await URLSession.shared.data(for: request)
    return (response as? HTTPURLResponse)?.statusCode == 200
}

func remoteFileExists(at url: URL) async -> Bool {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    request.timeoutInterval = 1.0 // Adjust to your needs
    guard let (_, response) = try? await URLSession.shared.data(for: request) else {
        return false
    }
    return (response as? HTTPURLResponse)?.statusCode == 200
}

enum ErrorDownloadFile: Error, LocalizedError {
    case remoteFileDoesntExist

    var errorDescription: String? {
        switch self {
        case .remoteFileDoesntExist:
            return NSLocalizedString(
                "The file is missing on the server",
                comment: "error message for remoteFileDoesntExist"
            )
        }
    }
}
