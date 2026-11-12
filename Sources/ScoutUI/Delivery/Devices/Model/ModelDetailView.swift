//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ModelDetailView: View {
    @StateObject private var provider: ModelDetailProvider

    @Environment(\.database) private var database

    init(model: String?, range: IncidentRange = .week, activities: [DeviceActivity]? = nil, provider: ModelDetailProvider? = nil) {
        _provider = StateObject(
            wrappedValue: provider ?? ModelDetailProvider(model: model, range: range, activities: activities)
        )
    }

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                ModelDetailPlaceholder(model: provider.modelName, range: $provider.range)
                    .transition(.opacity)
            case .success(let detail):
                content(detail)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: provider.modelName)
        .inlineNavigationTitle()
        .task(id: provider.range) {
            await provider.load(in: database)
        }
    }

    @ViewBuilder
    private func content(_ detail: ModelDetail) -> some View {
        if detail.devices.isEmpty {
            VStack(spacing: 0) {
                RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                Placeholder(
                    text: "No devices",
                    systemImage: "iphone.gen3",
                    description: "Devices appear here once this model reports a session"
                )
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                        .padding(.top, 8)

                    subtitle(detail)
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                        .overlay(alignment: .bottom) {
                            Separator()
                        }

                    if !detail.osVersions.isEmpty {
                        SectionHeader(title: "OS VERSIONS", topPadding: 12)

                        ProportionBar(
                            items: detail.osVersions,
                            color: { index, _ in deviceOSColor(index) },
                            share: { Double($0.percentage) / 100 }
                        )
                        .padding(.top, 14)
                        .padding(.bottom, 6)

                        ForEach(Array(detail.osVersions.enumerated()), id: \.element.id) { index, osVersion in
                            OSVersionRow(osVersion: osVersion, color: deviceOSColor(index))
                        }
                    }

                    SectionHeader(title: "DEVICES", topPadding: 12, showsSeparator: false)

                    deviceColumns
                        .columnHeaderStyle(topPadding: 12)

                    ForEach(detail.devices) { device in
                        NavigationLink {
                            DeviceDetailView(device: device, range: provider.range)
                        } label: {
                            ModelDeviceRow(device: device, maxSessions: detail.maxSessions)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func subtitle(_ detail: ModelDetail) -> some View {
        (Text(verbatim: "\(detail.deviceCount) \(detail.deviceCount == 1 ? "device" : "devices") · \(detail.sessionCount.compact) sessions · ")
            + Text(verbatim: "\(detail.crashCount)").foregroundColor(detail.crashCount > 0 ? .crashText : Color(.systemGray)).font(.system(size: 15, weight: .semibold))
            + Text(verbatim: " \(detail.crashCount == 1 ? "crash" : "crashes")"))
            .font(.weight450(size: 15))
            .foregroundStyle(Color(.systemGray))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var deviceColumns: some View {
        HStack(spacing: 8) {
            ColumnHeader(title: "LAST SEEN ↓", color: .blue)
                .frame(width: 84, alignment: .leading)
            ColumnHeader(title: "SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OS")
                .frame(width: 44, alignment: .leading)
            ColumnHeader(title: "CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
    }
}

private struct OSVersionRow: View {
    let osVersion: DeviceOSUsage
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
                .frame(width: 14, alignment: .leading)

            (Text(verbatim: osVersion.version).font(.system(size: 13, weight: .semibold, design: .monospaced))
                + Text(verbatim: " · \(osVersion.devices) \(osVersion.devices == 1 ? "device" : "devices")")
                .font(.weight450(size: 13))
                .foregroundColor(Color(.systemGray)))
                .font(.weight450(size: 13, design: .monospaced))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: osVersion.sessions.compact)
                .font(.weight450(size: 13, design: .monospaced))
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)

            Text(verbatim: osVersion.percentageText)
                .font(.weight450(size: 13, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color(.systemGray))
                .frame(width: 56, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
    }
}

private func deviceOSColor(_ index: Int) -> Color {
    let colors: [Color] = [.deviceAccent, .deviceAccentSoft, .deviceTrack]
    return colors[index % colors.count]
}

private struct ModelDeviceRow: View {
    let device: DeviceSummary
    let maxSessions: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: device.lastSeen.relativeString)
                .font(.weight450(size: 13))
                .lineLimit(1)
                .frame(width: 84, alignment: .leading)

            BarValue(text: device.sessions.compact, fraction: share, color: .deviceTrack)

            Text(verbatim: osVersion)
                .font(.weight450(size: 12, design: .monospaced))
                .foregroundStyle(Color(.systemGray))
                .lineLimit(1)
                .frame(width: 44, alignment: .leading)

            Text(verbatim: device.crashes > 0 ? "\(device.crashes)" : "—")
                .font(device.crashes > 0 ? .system(size: 13, weight: .bold, design: .monospaced) : .weight450(size: 13, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(device.crashes > 0 ? Color.crashText : Color.pending)
                .frame(width: 56, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }

    private var osVersion: String {
        DeviceOSRange(versions: [device.osVersion]).shortLabel ?? device.osVersion
    }

    private var share: Double {
        maxSessions > 0 ? Double(device.sessions) / Double(maxSessions) : 0
    }
}

#Preview("Model") {
    NavigationStack {
        ModelDetailView(
            model: "iPhone16,1",
            provider: .init(.success(.sample), model: "iPhone16,1")
        )
    }
}

#Preview("Model loading") {
    NavigationStack {
        ModelDetailPlaceholder(model: "iPhone 15 Pro", range: .constant(.week))
    }
}
