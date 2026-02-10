import Dependencies
import Speech
import XCTestDynamicOverlay

extension SpeechClient: TestDependencyKey {
    public static var previewValue: Self {
        let isRecording = LockIsolated(false)

        return Self(
            finishTask: { isRecording.setValue(false) },
            requestAuthorization: { .authorized },
            startTask: { _, _ in
                AsyncThrowingStream { continuation in
                    Task {
                        isRecording.setValue(true)
                        var finalText = """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
                        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
                        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute \
                        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla \
                        pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \
                        officia deserunt mollit anim id est laborum.
                        """
                        var text = ""
                        while isRecording.value {
                            let word = finalText.prefix { $0 != " " }
                            try await Task.sleep(for: .milliseconds(word.count * 50 + .random(in: 0 ... 200)))
                            finalText.removeFirst(word.count)
                            if finalText.first == " " {
                                finalText.removeFirst()
                            }
                            text += word + " "
                            continuation.yield(
                                SpeechRecognitionResult(
                                    bestTranscription: Transcription(
                                        formattedString: text,
                                        segments: []
                                    ),
                                    isFinal: false,
                                    transcriptions: []
                                )
                            )
                        }
                    }
                }
            },
            startFile: { _, _ in
                AsyncThrowingStream { continuation in
                    Task {
                        isRecording.setValue(true)
                        var finalText = """
                        Lorem ipsum
                        """
                        var text = ""
                        while isRecording.value {
                            let word = finalText.prefix { $0 != " " }
                            try await Task.sleep(for: .milliseconds(word.count * 50 + .random(in: 0 ... 200)))
                            finalText.removeFirst(word.count)
                            if finalText.first == " " {
                                finalText.removeFirst()
                            }
                            text += word + " "
                            continuation.yield(
                                SpeechRecognitionResult(
                                    bestTranscription: Transcription(
                                        formattedString: text,
                                        segments: []
                                    ),
                                    isFinal: false,
                                    transcriptions: []
                                )
                            )
                        }
                    }
                }
            },
            recognizeAudioChunk: { _, _, _ in
                [
                    "open documents",
                    "open docs"
                ]
            }
        )
    }

    public static let testValue = Self(
        finishTask: unimplemented("\(Self.self).finishTask"),
        requestAuthorization: unimplemented(
            "\(Self.self).requestAuthorization",
            placeholder: .notDetermined
        ),
        startTask: unimplemented("\(Self.self).recognitionTask", placeholder: .never),
        startFile: unimplemented("\(Self.self).recognitionTask", placeholder: .never),
        recognizeAudioChunk: unimplemented("\(Self.self).recognizeAudioChunk")
    )
}

extension DependencyValues {
    public var sfspeech: SpeechClient {
        get { self[SpeechClient.self] }
        set { self[SpeechClient.self] = newValue }
    }
}
