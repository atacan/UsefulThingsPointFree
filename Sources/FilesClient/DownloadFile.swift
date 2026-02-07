//import Foundation
//
//actor DownloadFile {
//
//    var downloadTask: URLSessionDownloadTask?
//    var delegate: DownloadFileDelegate?
//
//    func startDownloading(url: URL, to destination: URL) async throws -> AsyncThrowingStream<DownloadFileResult, Error>
//    {
//        if let downloadTask = self.downloadTask {
//            self.finishTask()
//        }
//        
//        let stream = AsyncThrowingStream<DownloadFileResult, Error> { continuation in
//            self.delegate = DownloadFileDelegate(
//                didWriteData: { progress in
//                    continuation.yield(.progress(progress))
//                },
//                didFinishDownloadingTo: { url in
//                    do {
//                        try FileManager.default.moveItem(at: url, to: destination)
//                        continuation.finish()
//                    }
//                    catch {
//                        continuation.finish(throwing: error)
//                    }
//                    continuation.yield(.didFinishDownloadingTo(url))
//                },
//                didCompleteWithError: { error in
//                    continuation.finish(throwing: error)
//                }
//            )
//            var urlSession = URLSession(
//                configuration: .default,
//                delegate: self.delegate,
//                delegateQueue: nil
//            )
//            let downloadTask = urlSession.downloadTask(with: url)
//            downloadTask.resume()
//            self.downloadTask = downloadTask
//
//            continuation.onTermination = { _ in
//                Task { await self.finishTask() }
//            }
//        }
//
//        return stream
//    }
//
//    func finishTask() {
//        if let downloadTask = self.downloadTask {
//            downloadTask.cancel()
//            self.downloadTask = nil
//            self.delegate = nil
//        }
//    }
//}
//
//public enum DownloadFileResult {
//    case progress(Float)
//    case didFinishDownloadingTo(URL)
//    case didCompleteWithError(Error)
//}
//
//class DownloadFileDelegate: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
//
//    let didWriteData: @Sendable (Float) -> Void
//    let didFinishDownloadingTo: @Sendable (URL) -> Void
//    let didCompleteWithError: @Sendable (Error) -> Void
//
//    init(
//        didWriteData: @escaping @Sendable (Float) -> Void,
//        didFinishDownloadingTo: @escaping @Sendable (URL) -> Void,
//        didCompleteWithError: @escaping @Sendable (Error) -> Void
//    ) {
//        self.didWriteData = didWriteData
//        self.didFinishDownloadingTo = didFinishDownloadingTo
//        self.didCompleteWithError = didCompleteWithError
//    }
//
//    func urlSession(
//        _ session: URLSession,
//        downloadTask: URLSessionDownloadTask,
//        didWriteData bytesWritten: Int64,
//        totalBytesWritten: Int64,
//        totalBytesExpectedToWrite: Int64
//    ) {
//        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//        didWriteData(calculatedProgress)
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        didFinishDownloadingTo(location)
//    }
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let error = error {
//            didCompleteWithError(error)
//        }
//    }
//}
