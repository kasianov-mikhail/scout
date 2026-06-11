//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A button that copies `text` to the system pasteboard, briefly turning
/// its icon into a checkmark to confirm the copy.
///
struct CopyButton: View {
    let text: String

    @State private var isCopied = false
    @State private var revertTask: Task<Void, Never>?

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            isCopied = true

            revertTask?.cancel()
            revertTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                isCopied = false
            }
        } label: {
            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
        }
        .animation(.easeInOut(duration: 0.15), value: isCopied)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        Text(verbatim: "Content")
            .navigationTitle(en: "Copy Button")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CopyButton(text: "Copied text")
                }
            }
    }
}
