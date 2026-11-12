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
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                trailing()
            }
            .padding(.top, 12)
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
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.day.timeline.left")
                            .font(.weight450(size: 17))
                            .foregroundStyle(.blue)
                            .frame(width: 24)

                        Text(verbatim: "Show in timeline")
                            .font(.weight450(size: 17))
                            .foregroundStyle(.blue)

                        Spacer(minLength: 0)
                    }
                    .lineLimit(1)
                    .frame(height: 52)
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
