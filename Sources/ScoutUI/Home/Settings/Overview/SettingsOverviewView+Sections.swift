//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import SwiftUI

extension SettingsOverviewView {
    @ViewBuilder
    var readFromSection: some View {
        SettingsLabel(title: "READ FROM")

        if health.backends.isEmpty {
            SettingsCard {
                Text(verbatim: "No backends configured.")
                    .font(.scoutRow)
                    .foregroundStyle(Color.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, .space8)
                    .padding(.vertical, .space10)
            }
        } else {
            SettingsStrip {
                ForEach(health.backends) { backend in
                    NavigationLink {
                        BackendDetailView(provider: health, id: backend.id, activeID: $activeID)
                    } label: {
                        SettingsSegmentCell(
                            title: backend.name,
                            detail: backend.detailLabel,
                            state: backend.segmentState,
                            isSelected: backend.id == activeID,
                            showsDivider: backend.id != health.backends.last?.id
                        )
                    }
                    .buttonStyle(.solid)
                }
            }
        }

        SettingsNote(text: "All backends get the data. Scout reads from the one you pick.")
    }

    @ViewBuilder
    var alertsSection: some View {
        if notificationsDenied {
            SettingsLabel(title: "ALERT PUSHES")

            NotificationsDeniedRow()
        }
    }

    @ViewBuilder
    var sendingSection: some View {
        SettingsLabel(title: "SENDING FROM THIS IPHONE")

        SettingsCard {
            SendReadout(summary: send)
        }

        SettingsNote(text: "Scout sends and checks in the background on its own.")
    }

    @ViewBuilder
    var cacheSection: some View {
        SettingsLabel(title: "CACHE")

        SettingsCard {
            HStack(spacing: 0) {
                SettingsReadoutRow(
                    value: cacheStatus.bytes == nil ? nil : cacheStatus.sizeLabel,
                    caption: cacheStatus.bytes == nil ? nil : "on this iPhone",
                    captionSkeletonWidth: cacheStatus.bytes == nil ? 74 : nil
                )

                SettingsCardAction(title: "Clear", color: .textDanger) {
                    isClearing = true
                }
            }
        }
    }

    var versionLabel: some View {
        Text(verbatim: version)
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
            .padding(.top, .space22)
    }

    var version: String {
        Bundle.main.marketingVersion.map { "Scout \($0)" } ?? "Scout"
    }
}
