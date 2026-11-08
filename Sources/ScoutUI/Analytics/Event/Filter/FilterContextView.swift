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
        VStack(alignment: .leading, spacing: 22) {
            FilterSection(title: "Session ID") {
                FilterIDField(
                    placeholder: "From a session or timeline",
                    text: $draft.sessionText,
                    isValid: draft.isSessionValid
                )
            }

            FilterSection(title: "Device ID") {
                FilterIDField(
                    placeholder: "From a device or session",
                    text: $draft.deviceText,
                    isValid: draft.isDeviceValid
                )
            }
        }
    }
}

private struct FilterIDField: View {
    let placeholder: String
    @Binding var text: String
    let isValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FilterBox {
                HStack(spacing: 0) {
                    Text(verbatim: text.isEmpty ? placeholder : text)
                        .font(text.isEmpty ? .weight450(size: 17) : .weight450(size: 15, design: .monospaced))
                        .foregroundStyle(!isValid ? Color.red : text.isEmpty ? Color(.systemGray3) : Color.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: toggle) {
                        Text(verbatim: text.isEmpty ? "Paste" : "Clear")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.blue)
                            .padding(.horizontal, 16)
                            .frame(maxHeight: .infinity)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray3))
                                    .frame(width: 0.5)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 44)
            }

            if !isValid {
                Text(verbatim: "Not a valid ID")
                    .font(.weight450(size: 13))
                    .foregroundStyle(.red)
            }
        }
    }

    private var clipboardText: String? {
        #if os(iOS)
            UIPasteboard.general.string
        #else
            NSPasteboard.general.string(forType: .string)
        #endif
    }

    private func toggle() {
        guard text.isEmpty else {
            text = ""
            return
        }
        text = clipboardText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

#Preview {
    FilterContextView(draft: FilterDraft(query: .constant(EventQuery())))
        .padding(16)
}
