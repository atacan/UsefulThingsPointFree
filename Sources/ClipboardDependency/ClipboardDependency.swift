import Dependencies
import Foundation

public struct ClipboardClient {
    public var copyString: (String) -> Void
    public var getString: () -> String?
    public var copyAttributedString: (NSAttributedString) -> Void
    public var getAttributedString: () -> NSAttributedString?
}

#if os(macOS)
    import Cocoa

    extension ClipboardClient: DependencyKey {
        public static var liveValue: Self {
            Self(
                copyString: { text in
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                },
                getString: { NSPasteboard.general.string(forType: .string) },
                copyAttributedString: { attributedText in
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([attributedText])
                },
                getAttributedString: {
                    NSPasteboard.general.readObjects(forClasses: [NSAttributedString.self], options: nil)?.first as? NSAttributedString
                }
            )
        }
    }
#endif

#if os(iOS)
    import UIKit
    import UniformTypeIdentifiers   // ⇢ UTType.rtf.identifier

    extension ClipboardClient: DependencyKey {

        public static var liveValue: Self {
            Self(
                // -----------------------------------------------------------------
                // 1️⃣ Copy a plain string to the pasteboard
                // -----------------------------------------------------------------
                copyString: { text in
                    UIPasteboard.general.string = text
                },

                // -----------------------------------------------------------------
                // 2️⃣ Retrieve a plain string from the pasteboard
                // -----------------------------------------------------------------
                getString: {
                    UIPasteboard.general.string
                },

                // -----------------------------------------------------------------
                // 3️⃣ Copy an NSAttributedString as RTF (and also as plain text)
                // -----------------------------------------------------------------
                copyAttributedString: { attributedText in
                    // a) Plain‑text representation – most apps look for this.
                    UIPasteboard.general.string = attributedText.string

                    // b) Convert the attributed string to RTF data.
                    //    If the conversion throws we simply ignore the RTF part;
                    //    the plain‑text copy above is still available.
                    let rtfData: Data? = {
                        do {
                            return try attributedText.data(
                                from: NSRange(location: 0, length: attributedText.length),
                                documentAttributes: [
                                    .documentType: NSAttributedString.DocumentType.rtf
                                ]
                            )
                        } catch {
                            // Optional: log the error in your own diagnostics system.
                            // print("⚠︎ Failed to generate RTF data: \(error)")
                            return nil
                        }
                    }()

                    // c) Store the RTF blob on the pasteboard, if we managed to create it.
                    if let rtf = rtfData {
                        UIPasteboard.general.setData(rtf, forPasteboardType: UTType.rtf.identifier)
                    }
                },

                // -----------------------------------------------------------------
                // 4️⃣ Retrieve an NSAttributedString from the RTF representation
                // -----------------------------------------------------------------
                getAttributedString: {
                    // Grab the RTF payload (if any) from the pasteboard.
                    guard let rtfData = UIPasteboard.general.data(forPasteboardType: UTType.rtf.identifier) else {
                        return nil
                    }

                    // Decode the data back into an attributed string.
                    // If the data is malformed we return nil.
                    do {
                        return try NSAttributedString(
                            data: rtfData,
                            options: [.documentType: NSAttributedString.DocumentType.rtf],
                            documentAttributes: nil
                        )
                    } catch {
                        // Optional: log the parsing error.
                        // print("⚠︎ Failed to decode RTF data: \(error)")
                        return nil
                    }
                }
            )
        }
    }
#endif

extension DependencyValues {
    public var clipboard: ClipboardClient.Value {
        get { self[ClipboardClient.self] }
        set { self[ClipboardClient.self] = newValue }
    }
}
