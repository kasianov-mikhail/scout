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
            VStack(spacing: 0) {
                switch context.result {
                case .success(let value):
                    let chips = value.chips
                    if !chips.isEmpty {
                        ChipRow {
                            ForEach(chips, id: \.self) { chip in
                                OutlineChip(text: chip.text, monospaced: chip.monospaced)
                            }
                        }
                    }
                    sessionRow {
                        Text(verbatim: value.sessionSummary)
                            .font(.scoutBody)
                            .lineLimit(1)
                    }
                case .failure(let error):
                    ErrorRow(description: error.localizedDescription) {
                        await context.fetchAgain(in: database)
                    }
                case nil:
                    ChipRow {
                        ForEach([120, 74, 74], id: \.self) { width in
                            SkeletonBar(width: CGFloat(width), height: .outlineChipHeight, delay: 0.08, cornerRadius: .radiusBlock)
                        }
                    }
                    sessionRow {
                        SkeletonBar(width: 120, height: 11, delay: 0.24)
                    }
                }
            }
        }

        private func sessionRow(@ViewBuilder value makeValue: () -> some View) -> some View {
            let value = makeValue()

            return NavigationLink {
                SessionInspector(sessionID: sessionID, deviceID: deviceID)
            } label: {
                HStack(spacing: .space12) {
                    Image(systemName: "clock")
                        .font(.scoutBody)
                        .foregroundStyle(Color.textLink)
                        .frame(width: 24)

                    Text(verbatim: "Session")
                        .font(.scoutRow)
                        .foregroundStyle(Color.eventContextLabel)

                    Spacer(minLength: 0)

                    value
                }
                .lineLimit(1)
                .frame(height: 52)
                .contentShape(.rect)
            }
            .buttonStyle(.solid)
        }
    }

    struct ChipRow<Content: View>: View {
        @ViewBuilder let content: () -> Content

        var body: some View {
            FlowLayout(spacing: .space6) {
                content()
            }
            .padding(.top, .space12)
            .padding(.bottom, .space12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }
}

#Preview("Chips") {
    let chips = [
        EventContext.Chip(text: "iPhone 15 Pro", monospaced: false),
        EventContext.Chip(text: "iOS 17.4", monospaced: false),
        EventContext.Chip(text: "en-US", monospaced: true),
        EventContext.Chip(text: "2.3.1 (412)", monospaced: true),
        EventContext.Chip(text: "TestFlight", monospaced: false),
    ]

    return VStack(spacing: 0) {
        EventView.ChipRow {
            ForEach(chips, id: \.self) { chip in
                OutlineChip(text: chip.text, monospaced: chip.monospaced)
            }
        }
    }
    .padding(.horizontal, .gutter)
}
