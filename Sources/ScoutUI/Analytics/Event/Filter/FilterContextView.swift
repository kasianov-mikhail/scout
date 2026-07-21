//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterContextView: View {
    @ObservedObject var draft: FilterDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Header(title: "Context")

            VStack(alignment: .leading, spacing: 10) {
                IDField(
                    title: "Session ID",
                    text: $draft.sessionText,
                    isValid: draft.isSessionValid
                )
                IDField(
                    title: "Device ID",
                    text: $draft.deviceText,
                    isValid: draft.isDeviceValid
                )
            }
        }
    }
}

private struct IDField: View {
    let title: String
    @Binding var text: String
    let isValid: Bool

    var body: some View {
        HStack {
            Text(verbatim: title).font(.callout)
            Spacer()
            if text.isEmpty {
                Button(action: paste) {
                    Image(systemName: "clipboard").font(.body)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            } else {
                VStack(alignment: .trailing, spacing: 1) {
                    Text(verbatim: text)
                        .font(.callout.monospaced())
                        .foregroundStyle(isValid ? Color.primary : Color.red)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    if !isValid {
                        Text(verbatim: "Not a valid ID").font(.caption).foregroundStyle(.red)
                    }
                }
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .softCell()
    }

    private func paste() {
        #if os(iOS)
            let string = UIPasteboard.general.string
        #else
            let string = NSPasteboard.general.string(forType: .string)
        #endif
        if let string {
            text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
