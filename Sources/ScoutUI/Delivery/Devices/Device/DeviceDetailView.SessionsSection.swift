//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension DeviceDetailView {
    struct SessionsSection: View {
        let detail: DeviceDetail
        let deviceID: UUID

        var body: some View {
            Section(title: "Sessions") {
                NavigationLink {
                    Timeline(deviceID: deviceID)
                } label: {
                    Text(verbatim: "TIMELINE")
                        .font(.scoutSectionAction)
                        .foregroundStyle(Color.textLink)
                }
                .buttonStyle(.solid)
            } content: {
                if detail.recentSessions.isEmpty {
                    Empty()
                } else {
                    ForEach(Array(detail.recentSessions.enumerated()), id: \.element.id) { index, session in
                        sessionRow(
                            session,
                            deviceID: detail.summary.id,
                            maxDuration: detail.maxSessionDuration,
                            showsDivider: index < detail.recentSessions.count - 1
                        )
                    }
                }
            }
        }

        @ViewBuilder
        private func sessionRow(_ session: DeviceSession, deviceID: UUID, maxDuration: TimeInterval, showsDivider: Bool) -> some View {
            if let sessionID = session.sessionID {
                NavigationLink {
                    SessionInspector(sessionID: sessionID, deviceID: deviceID)
                } label: {
                    SessionLine(session: session, maxDuration: maxDuration, showsDivider: showsDivider)
                }
                .buttonStyle(.solid)
            } else {
                SessionLine(session: session, maxDuration: maxDuration, showsDivider: showsDivider)
            }
        }

        private struct Empty: View {
            var body: some View {
                Text(verbatim: "No sessions in this period")
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
                    .frame(height: .rowRegular)
            }
        }

        struct Placeholder: View {
            var body: some View {
                Section(title: "Sessions") {
                    Text(verbatim: "TIMELINE")
                        .font(.scoutSectionAction)
                        .foregroundStyle(Color.textLink)
                } content: {
                    ForEach(0..<5, id: \.self) { index in
                        sessionRow(index: index, showsDivider: index < 4)
                    }
                }
            }

            private func sessionRow(index: Int, showsDivider: Bool) -> some View {
                let delay = 0.24 + Double(index) * 0.08

                return HStack(spacing: .space8) {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 8, height: 8)

                    SkeletonBar(width: 46, height: 9, delay: delay)
                        .frame(width: 76, alignment: .leading)

                    SkeletonBar(width: 28, height: 9, delay: delay)
                        .padding(.leading, .space4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    SkeletonBar(width: 28, height: 9, delay: delay)
                        .frame(width: 44, alignment: .trailing)
                }
                .frame(height: .rowRegular)
                .overlay(alignment: .bottom) {
                    if showsDivider {
                        Separator.dashed
                    }
                }
            }
        }
    }
}
