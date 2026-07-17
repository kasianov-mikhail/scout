//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

/// A button that copies `text` to the system pasteboard, briefly turning
/// its icon into a checkmark to confirm the copy.
///
struct CopyButton: View {
    let text: String

    @State private var isCopied = false
    @State private var copyCount = 0
    @State private var revert = DebouncedReset()

    var body: some View {
        Button {
            #if os(iOS)
                UIPasteboard.general.string = text
            #else
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            #endif
            isCopied = true
            copyCount += 1

            revert.schedule(after: .seconds(2)) {
                isCopied = false
            }
        } label: {
            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
        }
        .animation(.easeInOut(duration: 0.15), value: isCopied)
        .hapticFeedback(.success, trigger: copyCount)
    }
}

#Preview {
    NavigationStack {
        Text(verbatim: "Content")
            .navigationTitle(en: "Copy Button")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CopyButton(text: "Copied text")
                }
            }
    }
}
