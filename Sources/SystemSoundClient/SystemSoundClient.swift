import AudioToolbox
import Dependencies

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public struct SystemSoundClient {
    public var play: @Sendable (SystemSound.Name) -> Void
}

extension DependencyValues {
    public var systemSound: SystemSoundClient {
        get { self[SystemSoundClient.self] }
        set { self[SystemSoundClient.self] = newValue }
    }
}

extension SystemSoundClient: DependencyKey {
    public static let liveValue = Self(
        play: { systemSoundName in
            SystemSound.play(systemSoundName)
        }
    )
}

public class SystemSound {
    /// Name
    public struct Name {
        #if os(macOS)
        fileprivate let filepath: String?
        fileprivate let soundID: SystemSoundID?
        
        fileprivate init(filepath: String) {
            self.filepath = filepath
            self.soundID = nil
        }
        
        fileprivate init(soundID: SystemSoundID) {
            self.filepath = nil
            self.soundID = soundID
        }
        #elseif os(iOS)
        fileprivate let soundID: SystemSoundID?
        fileprivate let resourceFilename: String?
        
        fileprivate init(soundID: SystemSoundID) {
            self.soundID = soundID
            self.resourceFilename = nil
        }
        
        fileprivate init(resourceFilename: String) {
            self.soundID = nil
            self.resourceFilename = resourceFilename
        }
        #endif
        
        /// Cross-platform system sounds
        #if os(macOS)
        public static let volume_mount = Name(filepath: "system/Volume Mount.aif")
        public static let begin_record = Name(filepath: "system/begin_record.caf")
        public static let end_record = Name(filepath: "system/end_record.caf")
        public static let move_to_trash = Name(filepath: "finder/move to trash.aif")
        public static let media_keys = Name(filepath: "system/Media Keys.aif")
        public static let mic_unmute_fail = Name(filepath: "system/mic_unmute_fail.caf")
        
        // Additional macOS system sounds that can be used with sound IDs
        public static let alert = Name(soundID: kSystemSoundID_UserPreferredAlert)
        #elseif os(iOS)
        // Cross-platform system sounds using bundled resources
        public static let begin_record = Name(resourceFilename: "begin_record.caf")
        public static let end_record = Name(resourceFilename: "end_record.caf")
        public static let media_keys = Name(resourceFilename: "Media Keys.aif")
        public static let mic_unmute_fail = Name(resourceFilename: "mic_unmute_fail.caf")
        // iOS system sounds using predefined IDs
        public static let receivedMessage = Name(soundID: 1007) // Text message received
        public static let sentMessage = Name(soundID: 1004) // Text message sent
        public static let mailReceived = Name(soundID: 1000) // Mail received
        public static let mailSent = Name(soundID: 1001) // Mail sent
        public static let voicemail = Name(soundID: 1002) // Voicemail
        public static let tweet = Name(soundID: 1016) // Tweet
        public static let anticipate = Name(soundID: 1020) // Anticipate
        public static let bloom = Name(soundID: 1021) // Bloom
        public static let calypso = Name(soundID: 1022) // Calypso
        public static let choo_choo = Name(soundID: 1023) // Choo Choo
        public static let descent = Name(soundID: 1024) // Descent
        public static let fanfare = Name(soundID: 1025) // Fanfare
        public static let ladder = Name(soundID: 1026) // Ladder
        public static let minuet = Name(soundID: 1027) // Minuet
        public static let news_flash = Name(soundID: 1028) // News Flash
        public static let noir = Name(soundID: 1029) // Noir
        public static let sherwood_forest = Name(soundID: 1030) // Sherwood Forest
        public static let spell = Name(soundID: 1031) // Spell
        public static let suspense = Name(soundID: 1032) // Suspense
        public static let telegraph = Name(soundID: 1033) // Telegraph
        public static let tiptoes = Name(soundID: 1034) // Tiptoes
        public static let typewriters = Name(soundID: 1035) // Typewriters
        public static let update = Name(soundID: 1036) // Update
        
        // System control sounds
        public static let vibrate = Name(soundID: kSystemSoundID_Vibrate) // Vibration (iOS only)
        #endif
    }

    /// Play given sound
    public static func play(_ systemSoundName: Name) {
        #if os(macOS)
        if let soundID = systemSoundName.soundID {
            // Use predefined sound ID
            AudioServicesPlaySystemSound(soundID)
        } else if let filepath = systemSoundName.filepath {
            // Use file path for macOS system sounds
            let url = URL(
                fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/\(filepath)"
            )
            var soundID: SystemSoundID = 0
            let result = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            if result == noErr {
                AudioServicesPlaySystemSound(soundID)
                // Clean up the sound ID after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    AudioServicesDisposeSystemSoundID(soundID)
                }
            }
        }
        #elseif os(iOS)
        if let soundID = systemSoundName.soundID {
            // Use predefined sound ID
            AudioServicesPlaySystemSound(soundID)
        } else if let resourceFilename = systemSoundName.resourceFilename {
            // Use bundled resource file
            guard let url = Bundle.module.url(forResource: resourceFilename.replacingOccurrences(of: ".aif", with: "").replacingOccurrences(of: ".caf", with: ""), withExtension: resourceFilename.hasSuffix(".aif") ? "aif" : "caf") else {
                return
            }
            var soundID: SystemSoundID = 0
            let result = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            if result == noErr {
                AudioServicesPlaySystemSound(soundID)
                // Clean up the sound ID after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    AudioServicesDisposeSystemSoundID(soundID)
                }
            }
        }
        #endif
    }
}
