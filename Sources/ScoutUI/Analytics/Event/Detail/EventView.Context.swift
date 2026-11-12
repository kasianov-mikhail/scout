//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EventView {
    struct ContextSection: View {
        let sessionID: UUID
        let deviceID: UUID?

        @Environment(\.database) private var database
        @ObservedObject var context: EventContextProvider

        var body: some View {
            switch context.result {
            case .success(let value):
                let chips = value.chips
                if !chips.isEmpty {
                    chipRow {
                        ForEach(chips, id: \.self) { chip in
                            OutlineChip(text: chip.text, monospaced: chip.monospaced)
                        }
                    }
                }
                sessionRow {
                    Text(verbatim: value.sessionSummary)
                        .font(.weight450(size: 17))
                        .lineLimit(1)
                }
            case .failure(let error):
                ErrorRow(description: error.localizedDescription) {
                    await context.fetchAgain(in: database)
                }
                .overlay(alignment: .bottom) {
                    Separator()
                }
            case nil:
                chipRow {
                    ForEach([120, 74, 74], id: \.self) { width in
                        SkeletonBar(width: CGFloat(width), height: 27, delay: 0.08, cornerRadius: 13.5)
                    }
                }
                sessionRow {
                    SkeletonBar(width: 120, height: 11, delay: 0.24)
                }
            }
        }

        private func chipRow(@ViewBuilder content: () -> some View) -> some View {
            FlowLayout(spacing: 6) {
                content()
            }
            .padding(.top, 12)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }

        private func sessionRow(@ViewBuilder value makeValue: () -> some View) -> some View {
            let value = makeValue()

            return NavigationLink {
                SessionInspector(sessionID: sessionID, deviceID: deviceID)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.weight450(size: 17))
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    Text(verbatim: "Session")
                        .font(.weight450(size: 15))
                        .foregroundStyle(Color.eventContextLabel)

                    Spacer(minLength: 0)

                    value
                }
                .lineLimit(1)
                .frame(height: .rowRegular)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }
}
