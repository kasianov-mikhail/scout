//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EventView {
    struct SectionHeader<Trailing: View>: View {
        let title: String
        @ViewBuilder var trailing: () -> Trailing

        var body: some View {
            HStack {
                Text(verbatim: title.uppercased())
                    .font(.scoutSection)

                Spacer()

                trailing()
            }
            .padding(.top, .space12)
            .frame(height: 56)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }
}

extension EventView {
    struct TimelineSection: View {
        let event: Event

        var body: some View {
            if let deviceID = event.deviceID {
                NavigationLink {
                    Timeline(deviceID: deviceID, focus: TimelineFocus(event: event))
                } label: {
                    HStack(spacing: .space12) {
                        Image(systemName: "calendar.day.timeline.left")
                            .font(.scoutBody)
                            .foregroundStyle(Color.textLink)
                            .frame(width: 24)

                        Text(verbatim: "Show in timeline")
                            .font(.scoutBody)
                            .foregroundStyle(Color.textLink)

                        Spacer(minLength: 0)
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
}
