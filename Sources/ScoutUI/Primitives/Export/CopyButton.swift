//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

/// A button that copies `text` to the system pasteboard, confirming the copy
/// with a success message presented by the enclosing screen.
///
struct CopyButton: View {
    let text: String

    @Binding var message: Message?
    @State private var copyCount = 0

    var body: some View {
        Button {
            #if os(iOS)
                UIPasteboard.general.string = text
            #else
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            #endif
            copyCount += 1
            message = Message("Copied to clipboard", level: .success)
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .hapticFeedback(.success, trigger: copyCount)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var message: Message?

    NavigationStack {
        Text(verbatim: "Content")
            .navigationTitle(en: "Copy Button")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CopyButton(text: "Copied text", message: $message)
                }
            }
            .message($message)
    }
}
