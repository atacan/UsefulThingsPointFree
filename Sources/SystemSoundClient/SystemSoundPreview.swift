#if DEBUG
import SwiftUI
import Dependencies

struct SystemSoundPreview: View {
    @Dependency(\.systemSound) var systemSound
    
    var body: some View {
        NavigationView {
            List {
                Section("Cross-Platform Sounds") {
                    #if os(macOS)
                    SoundButton(title: "Volume Mount", sound: .volume_mount)
                    #endif
                    SoundButton(title: "Begin Record", sound: .begin_record)
                    SoundButton(title: "End Record", sound: .end_record)
                    #if os(macOS)
                    SoundButton(title: "Move to Trash", sound: .move_to_trash)
                    #endif
                    SoundButton(title: "Media Keys", sound: .media_keys)
                    SoundButton(title: "Mic Unmute Fail", sound: .mic_unmute_fail)
                    #if os(macOS)
                    SoundButton(title: "Alert", sound: .alert)
                    #endif
                }
                
                #if os(iOS)
                Section("iOS System Sounds") {
                    SoundButton(title: "Received Message", sound: .receivedMessage)
                    SoundButton(title: "Sent Message", sound: .sentMessage)
                    SoundButton(title: "Mail Received", sound: .mailReceived)
                    SoundButton(title: "Mail Sent", sound: .mailSent)
                    SoundButton(title: "Voicemail", sound: .voicemail)
                    SoundButton(title: "Tweet", sound: .tweet)
                    SoundButton(title: "Anticipate", sound: .anticipate)
                    SoundButton(title: "Bloom", sound: .bloom)
                    SoundButton(title: "Calypso", sound: .calypso)
                    SoundButton(title: "Choo Choo", sound: .choo_choo)
                    SoundButton(title: "Descent", sound: .descent)
                    SoundButton(title: "Fanfare", sound: .fanfare)
                    SoundButton(title: "Ladder", sound: .ladder)
                    SoundButton(title: "Minuet", sound: .minuet)
                    SoundButton(title: "News Flash", sound: .news_flash)
                    SoundButton(title: "Noir", sound: .noir)
                    SoundButton(title: "Sherwood Forest", sound: .sherwood_forest)
                    SoundButton(title: "Spell", sound: .spell)
                    SoundButton(title: "Suspense", sound: .suspense)
                    SoundButton(title: "Telegraph", sound: .telegraph)
                    SoundButton(title: "Tiptoes", sound: .tiptoes)
                    SoundButton(title: "Typewriters", sound: .typewriters)
                    SoundButton(title: "Update", sound: .update)
                    SoundButton(title: "Vibrate", sound: .vibrate)
                }
                #endif
            }
            .navigationTitle("System Sounds")
        }
    }
}

struct SoundButton: View {
    let title: String
    let sound: SystemSound.Name
    @Dependency(\.systemSound) var systemSound
    
    var body: some View {
        Button(title) {
            systemSound.play(sound)
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    SystemSoundPreview()
}
#endif