//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct IncidentContextRows<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let group: IncidentGroup<Element>?
    let context: IncidentContext?
    let isLoading: Bool
    var fullyLoading = false

    var body: some View {
        if hasDevice {
            deviceRow
        }
        if let sessionID = element.sessionID {
            sessionRow(sessionID)
        }
        if let deviceID = element.deviceID {
            timelineRow(deviceID)
        }
        if let group {
            groupRow(group)
        }
    }

    private var hasDevice: Bool {
        element.deviceID != nil
    }

    private var hasSession: Bool {
        element.sessionID != nil
    }

    private var hasTimeline: Bool {
        element.deviceID != nil
    }

    private var hasGroup: Bool {
        group != nil
    }

    private var deviceRow: some View {
        IncidentContextRow(
            systemImage: "iphone",
            color: .fillAccent,
            label: isLoading ? nil : deviceLabel,
            value: isLoading ? nil : context?.osVersion,
            skeleton: isLoading,
            showsDivider: hasSession || hasTimeline || hasGroup,
            delay: 0.4
        )
    }

    private var deviceLabel: String {
        context?.model.map { DeviceModel(identifier: $0).name } ?? "Device"
    }

    private func sessionRow(_ sessionID: UUID) -> some View {
        NavigationLink {
            SessionInspector(sessionID: sessionID, deviceID: element.deviceID)
        } label: {
            IncidentContextRow(
                systemImage: "list.bullet.rectangle.portrait",
                color: .fillResource,
                label: "Session",
                value: isLoading ? nil : sessionValue(sessionID),
                skeleton: isLoading,
                showsDivider: hasTimeline || hasGroup,
                delay: 0.48
            )
        }
        .buttonStyle(.plain)
    }

    private func sessionValue(_ sessionID: UUID) -> String {
        context?.sessionText ?? ExportFormat.shortID(sessionID)
    }

    private func timelineRow(_ deviceID: UUID) -> some View {
        NavigationLink {
            Timeline(deviceID: deviceID, focus: element.detailFocus)
        } label: {
            IncidentContextRow(
                systemImage: "calendar.day.timeline.left",
                color: .fillAccent,
                label: "Timeline",
                value: isLoading ? nil : "this device",
                skeleton: isLoading,
                showsDivider: hasGroup,
                delay: 0.56
            )
        }
        .buttonStyle(.plain)
    }

    private func groupRow(_ group: IncidentGroup<Element>) -> some View {
        IncidentContextRow(
            systemImage: "square.on.square",
            color: Element.kind.color,
            label: element.detailGroupTitle,
            value: fullyLoading ? nil : groupText(group),
            skeleton: fullyLoading,
            showsDivider: false,
            delay: 0.64
        )
    }

    private func groupText(_ group: IncidentGroup<Element>) -> String {
        let count = group.count == 1 ? element.detailCount : "\(element.detailCount)s"
        let devices = group.affectedDevices == 1 ? "device" : "devices"
        return "\(group.occurrencesText) \(count) · \(group.devicesText) \(devices)"
    }
}

private struct IncidentContextRow: View {
    let systemImage: String
    let color: Color
    let label: String?
    let value: String?
    let skeleton: Bool
    let showsDivider: Bool
    let delay: Double

    var body: some View {
        HStack(spacing: .space10) {
            if skeleton {
                SkeletonBar(width: 18, height: 18, delay: delay, cornerRadius: .radiusBadge)
                    .frame(width: 24)
            } else {
                Image(systemName: systemImage)
                    .font(.scoutRow)
                    .frame(width: 24)
                    .foregroundStyle(color)
            }

            if skeleton, label == nil {
                SkeletonBar(width: 88, height: 9, delay: delay)
            } else if let label {
                Text(verbatim: label)
                    .font(.scoutRow)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if skeleton, value == nil {
                SkeletonBar(width: 74, height: 9, delay: delay)
            } else if let value {
                Text(verbatim: value)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
    }
}
