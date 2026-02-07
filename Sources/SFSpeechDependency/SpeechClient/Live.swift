import Dependencies
import Speech

public struct SpeechClient {
    public var finishTask: @Sendable () async -> Void
    public var requestAuthorization: @Sendable () async -> SFSpeechRecognizerAuthorizationStatus
    public var startTask: @Sendable (_ sfRequest: SFSpeechAudioBufferRecognitionRequest, _ locale: Locale) async
        -> AsyncThrowingStream<
            SpeechRecognitionResult,
            Error
        >
    public var startFile:
        @Sendable (SFSpeechURLRecognitionRequest, _ locale: Locale) async -> AsyncThrowingStream<
            SpeechRecognitionResult, Error
        >

    public var recognizeAudioChunk: @Sendable (_ sample: [Float], _ locale: Locale, _ configuration: SpeechRecognitionRequestConfiguration) async throws -> [String]

    enum Failure: Error, Equatable {
        case taskError
        case couldntStartAudioEngine
        case couldntConfigureAudioSession
        case couldntInitSFSpeechRecognizer
    }
}

extension SpeechClient: DependencyKey {
    public static var liveValue: Self {
        let speech = Speech()
        return Self(
            finishTask: {
                await speech.finishTask()
            },
            requestAuthorization: {
                await withCheckedContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { status in
                        continuation.resume(returning: status)
                    }
                }
            },
            startTask: { request, locale in
                let request = UncheckedSendable(request)
                return await speech.startTask(request: request, locale: locale)
            },
            startFile: { request, locale in
                let request = UncheckedSendable(request)
                return await speech.startFile(request: request, locale: locale)
            },
            recognizeAudioChunk: { sample, locale, configuration in
                return try await transcribeAudioSamples(sample, locale: locale, configuration: configuration)
            }
        )
    }
}

private actor Speech {
    var audioEngine: AVAudioEngine?
    var recognitionTask: SFSpeechRecognitionTask?
    var recognitionContinuation: AsyncThrowingStream<SpeechRecognitionResult, Error>.Continuation?

    func finishTask() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        recognitionContinuation?.finish()
    }

    func startTask(
        request: UncheckedSendable<SFSpeechAudioBufferRecognitionRequest>,
        locale: Locale = Locale(identifier: "en-US")
    ) -> AsyncThrowingStream<SpeechRecognitionResult, Error> {
        let request = request.wrappedValue

        return AsyncThrowingStream { continuation in
            self.recognitionContinuation = continuation
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                continuation.finish(throwing: SpeechClient.Failure.couldntConfigureAudioSession)
                return
            }
            #endif

            self.audioEngine = AVAudioEngine()
            guard let speechRecognizer = SFSpeechRecognizer(locale: locale) else {
                continuation.finish(throwing: SpeechClient.Failure.couldntInitSFSpeechRecognizer)
                return
            }
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                switch (result, error) {
                case let (.some(result), _):
                    continuation.yield(SpeechRecognitionResult(result))
                case (_, .some):
                    continuation.finish(throwing: SpeechClient.Failure.taskError)
                case (.none, .none):
                    fatalError("It should not be possible to have both a nil result and nil error.")
                }
            }

            continuation.onTermination = {
                [
                    speechRecognizer = UncheckedSendable(speechRecognizer),
                    audioEngine = UncheckedSendable(audioEngine),
                    recognitionTask = UncheckedSendable(recognitionTask)
                ]
                _ in

                _ = speechRecognizer
                audioEngine.wrappedValue?.stop()
                audioEngine.wrappedValue?.inputNode.removeTap(onBus: 0)
                recognitionTask.wrappedValue?.finish()
            }

            self.audioEngine?.inputNode
                .installTap(
                    onBus: 0,
                    bufferSize: 1024,
                    format: self.audioEngine?.inputNode.outputFormat(forBus: 0)
                ) { buffer, when in
                    request.append(buffer)
                }

            self.audioEngine?.prepare()
            do {
                try self.audioEngine?.start()
            } catch {
                continuation.finish(throwing: SpeechClient.Failure.couldntStartAudioEngine)
                return
            }
        }
    }

    func startFile(
        request: UncheckedSendable<SFSpeechURLRecognitionRequest>,
        locale: Locale = Locale(identifier: "en-US")
    ) -> AsyncThrowingStream<SpeechRecognitionResult, Error> {
        let request = request.wrappedValue

        return AsyncThrowingStream { continuation in
            self.recognitionContinuation = continuation
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                continuation.finish(throwing: SpeechClient.Failure.couldntConfigureAudioSession)
                return
            }
            #endif

            //        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
            // current locale
            guard let speechRecognizer = SFSpeechRecognizer() else {
                continuation.finish(throwing: SpeechClient.Failure.couldntInitSFSpeechRecognizer)
                return
            }
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                switch (result, error) {
                case let (.some(result), _):
                    continuation.yield(SpeechRecognitionResult(result))
                case (_, .some):
                    continuation.finish(throwing: SpeechClient.Failure.taskError)
                case (.none, .none):
                    fatalError("It should not be possible to have both a nil result and nil error.")
                }
            }

            continuation.onTermination = {
                [
                    speechRecognizer = UncheckedSendable(speechRecognizer),
                    audioEngine = UncheckedSendable(audioEngine),
                    recognitionTask = UncheckedSendable(recognitionTask)
                ]
                _ in

                _ = speechRecognizer
                audioEngine.wrappedValue?.stop()
                audioEngine.wrappedValue?.inputNode.removeTap(onBus: 0)
                recognitionTask.wrappedValue?.finish()
            }
        }
    }
}
