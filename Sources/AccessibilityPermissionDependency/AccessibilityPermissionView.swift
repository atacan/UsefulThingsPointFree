#if canImport(Cocoa)
import ComposableArchitecture
import OSLog
import SwiftUI

@Reducer
public struct AccessibilityPermission: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var isAccessibilityEnabled: Bool = false
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?

        public init(isAccessibilityEnabled: Bool = false) {
            self.isAccessibilityEnabled = isAccessibilityEnabled
        }
    }

    public enum Action {
        case openSystemSettingsButtonTouched
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case task

        @CasePathable
        public enum ConfirmationDialog {
            case continueButtonTapped
        }
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.accessibilityPermission) var accessibilityPermission
    let logger = Logger.init(subsystem: "AccessibilityPermission", category: "AccessibilityPermissionView")

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openSystemSettingsButtonTouched:
                let isAccessibilityEnabled = checkAccessibility(state: &state)
                if isAccessibilityEnabled {
                    return .none
                }

                state.confirmationDialog = ConfirmationDialogState {
                    TextState("Accessibility", bundle: .module, comment: "title of the dialogue to enable accessibility permission")
                } actions: {
                    ButtonState(action: .continueButtonTapped) {
                        TextState("Continue", bundle: .module, comment: "the button label to continue enabling accessibility permission")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel", bundle: .module, comment: "the button label to cancel enabling accessibility permission dialogue")
                    }
                } message: {
                    TextState(
                        "Click Continue to navigate to macOS System Settings > Privacy & Security > Accessibility. \nLocate this app in the list, and enable the toggle switch next to it.",
                        bundle: .module,
                        comment: "the message of the dialogue to enable accessibility permission"
                    )
                }
                return .none

            case .confirmationDialog(.presented(.continueButtonTapped)):
                state.confirmationDialog = nil
                guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
                else {
                    return .none
                }
                NSWorkspace.shared.open(url)
                return .run { send in
                    try await self.clock.sleep(for: .seconds(15))
                    await send(.task)
                } catch: { error, send in
                    logger.error("AccessibilityPermission: \(error)")
                }

            case .confirmationDialog:
                return .none

            case .task:
                _ = checkAccessibility(state: &state)
                return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }

    func checkAccessibility(state: inout State) -> Bool {
        let result = accessibilityPermission.checkIsProcessTrusted()
        state.isAccessibilityEnabled = result
        return result
    }
}

public struct AccessibilityPermissionView: View {
    let store: StoreOf<AccessibilityPermission>
    let description: LocalizedStringKey

    public init(store: StoreOf<AccessibilityPermission>, description: LocalizedStringKey) {
        self.store = store
        self.description = description
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Accessibility Permission", bundle: .module, comment: "the label for the accessibility switch")

                if !store.isAccessibilityEnabled {
                    Text(description)
                        .font(.footnote)
                }
            }
            Spacer()

            if store.isAccessibilityEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.green)
                    .frame(height: 16)
            } else {
                Button {
                    store.send(.openSystemSettingsButtonTouched)
                } label: {
                    Text("System Settings…", bundle: .module, comment: "the button label to open macOS System Settings > Privacy&Security > Accessibility")
                }
            }
        }
        .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: \.confirmationDialog))
        .task {
            store.send(.task)
        }
    }
}

#Preview {
    AccessibilityPermissionView(
        store: Store(
            initialState: AccessibilityPermission.State(),
            reducer: { AccessibilityPermission() }
        ),
        description: "Needed for pasting or typing"
    )
    .padding()
}
#endif
