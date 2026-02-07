# UsefulThingsPointFree

A collection of ready-to-use [Swift Dependencies](https://github.com/pointfreeco/swift-dependencies) and [TCA](https://github.com/pointfreeco/swift-composable-architecture) utilities for macOS and iOS apps. One package, 12 independent libraries — import only what you need.

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/atacan/UsefulThingsPointFree", from: "1.0.0")
```

Then add any combination of libraries to your target:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "ClipboardDependency", package: "UsefulThingsPointFree"),
        .product(name: "FilePanelsClient", package: "UsefulThingsPointFree"),
        // ... pick what you need
    ]
)
```

**Platforms:** macOS 14+ / iOS 16+
**Swift:** 5.9+

## Libraries

### AccessibilityPermissionDependency

Check and prompt for macOS accessibility permission with a built-in SwiftUI view and TCA reducer.

```swift
import AccessibilityPermissionDependency

@Dependency(\.accessibilityPermission) var accessibilityPermission
let isGranted = accessibilityPermission.checkPermission()
```

**Depends on:** Dependencies, ComposableArchitecture

---

### ClipboardDependency

Copy and paste plain text or attributed strings, with platform-specific implementations for macOS (`NSPasteboard`) and iOS (`UIPasteboard`).

```swift
import ClipboardDependency

@Dependency(\.clipboard) var clipboard
clipboard.copyString("Hello")
let text = clipboard.getString()
```

**Depends on:** Dependencies

---

### DismissDependency

Dependency wrapper around SwiftUI's `dismiss` environment action for programmatic view dismissal.

```swift
import DismissDependency

@Dependency(\.dismissEffect) var dismiss
dismiss()
```

**Depends on:** Dependencies

---

### DismissWindowDependency

Close a window by its identifier on macOS and iOS 17+.

```swift
import DismissWindowDependency

@Dependency(\.dismissWindow) var dismissWindow
dismissWindow(id: "settings")
```

**Depends on:** Dependencies

---

### FilePanelsClient

macOS open/save panel dialogs with file read/write operations in a single dependency.

```swift
import FilePanelsClient

@Dependency(\.filePanelsClient) var filePanels
let url = try await filePanels.openPanel(...)
let content = try filePanels.read(url)
```

**Depends on:** Dependencies

---

### FilesClient

Cross-platform file operations — read, write, download, create directories, delete, and open files with the default app.

```swift
import FilesClient

@Dependency(\.filesClient) var files
let data = try files.read(url)
let tempDir = files.temporaryDirectory()
try await files.download(from: remoteURL, to: localURL)
```

**Depends on:** Dependencies

---

### OpenWindowDependency

Open a new window by its identifier using SwiftUI's scene-based windowing system.

```swift
import OpenWindowDependency

@Dependency(\.openWindow) var openWindow
openWindow(id: "detail")
```

**Depends on:** Dependencies

---

### RequestReviewDependency

Trigger the StoreKit app review prompt as a testable dependency.

```swift
import RequestReviewDependency

@Dependency(\.requestReview) var requestReview
await requestReview()
```

**Depends on:** Dependencies

---

### SFSpeechDependency

Speech recognition from microphone input or audio files using Apple's Speech framework, with testable value types replacing framework reference types.

```swift
import SFSpeechDependency

@Dependency(\.speechClient) var speechClient
let status = await speechClient.requestAuthorization()
let result = try await speechClient.startTask(config)
```

**Depends on:** Dependencies

---

### SystemSoundClient

Play system sounds and audio alerts with bundled sound files for common actions like recording start/stop.

```swift
import SystemSoundClient

@Dependency(\.systemSound) var systemSound
systemSound.play(.beginRecord)
```

**Depends on:** Dependencies

---

### TCAComponents

TCA reducer utilities: an `onChange` hook that provides both old and new state values, plus a ready-made drag-and-drop file reducer and view.

```swift
import TCAComponents

Reduce { state, action in /* ... */ }
    .onChange(of: \.someValue) { oldValue, newValue in
        // side effect
    }
```

**Depends on:** ComposableArchitecture

---

### UserNotificationsDependency

Request notification permissions and send local notifications with title, subtitle, and body.

```swift
import UserNotificationsDependency

@Dependency(\.notificationClient) var notifications
try await notifications.requestAuthorization()
try await notifications.sendNotification(.init(title: "Done", body: "Export finished."))
```

**Depends on:** Dependencies, DependenciesMacros

## License

MIT
