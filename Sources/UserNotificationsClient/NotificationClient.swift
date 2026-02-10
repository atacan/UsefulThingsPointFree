import Dependencies
import UserNotifications

public struct NotificationClient {
    public var requestAuthorization: @Sendable () async throws -> Bool
    public var sendNotification: @Sendable (NotificationContent) async throws -> Void
}

extension NotificationClient: DependencyKey {
    public static var liveValue: Self {
        let unCenter = UNUserNotificationCenter.current()
        return Self(
            requestAuthorization: {
                try await unCenter.requestAuthorization(options: [.alert])
            },
            sendNotification: { content in
                let unContent = UNMutableNotificationContent()
                unContent.title = content.title
                unContent.subtitle = content.subtitle
                unContent.body = content.body

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "Immediate",
                    content: unContent,
                    trigger: trigger
                )  // Schedule the notification.
                try await unCenter.add(request)
            }
        )
    }
}

public struct NotificationContent {
    let title: String
    let subtitle: String
    let body: String

    public init(title: String, subtitle: String, body: String) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}

extension DependencyValues {
    public var notification: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}

extension NotificationClient {
    public static var previewValue: Self {
        Self(
            requestAuthorization: { true },
            sendNotification: { content in
                print("Notification sent: \(content)")
            }
        )
    }
}
