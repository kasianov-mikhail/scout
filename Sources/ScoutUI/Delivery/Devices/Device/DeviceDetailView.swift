//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DeviceDetailView: View {
    @StateObject private var provider: DeviceDetailProvider

    @Environment(\.database) private var database
    @State private var showTimeline = false

    init(device: DeviceSummary, range: IncidentRange = .week, provider: DeviceDetailProvider? = nil) {
        _provider = StateObject(wrappedValue: provider ?? DeviceDetailProvider(device: device, range: range))
    }

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                DeviceDetailPlaceholder(summary: provider.device, range: $provider.range)
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
        .navigationTitle(en: "Device")
        .inlineNavigationTitle()
        .navigationDestination(isPresented: $showTimeline) {
            Timeline(deviceID: provider.device.id)
        }
        .task(id: provider.range) {
            await provider.fetchAgain(in: database)
        }
    }

    private func content(_ detail: DeviceDetail) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, .space8)

                subtitle(detail.summary)
                    .padding(.top, .space4)
                    .padding(.bottom, .space12)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }

                stats(detail)

                SectionHeader(title: "SESSIONS", topPadding: 12) {
                    Button {
                        showTimeline = true
                    } label: {
                        Text(verbatim: "TIMELINE")
                            .font(.scoutSectionAction)
                            .foregroundStyle(Color.textLink)
                    }
                    .buttonStyle(.plain)
                }

                if detail.recentSessions.isEmpty {
                    Text(verbatim: "No sessions in this period")
                        .font(.scoutRow)
                        .foregroundStyle(Color.textMuted)
                        .lineLimit(1)
                        .frame(height: .rowRegular)
                } else {
                    ForEach(detail.recentSessions) { session in
                        sessionRow(session, deviceID: detail.summary.id, maxDuration: detail.maxSessionDuration)
                    }
                }

                if !detail.history.isEmpty {
                    spacer(8)

                    SectionHeader(title: "HISTORY", topPadding: 12)

                    ForEach(Array(detail.history.enumerated()), id: \.element.id) { index, event in
                        HistoryRow(event: event, isLast: index == detail.history.count - 1)
                    }
                }

                spacer(12)

                SectionHeader(title: "ACTIVITY", topPadding: 12) {
                    Text(verbatim: detail.activeDaysLabel)
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                }

                DeviceActivityChart(points: detail.activity, showsCounts: detail.range != .month)
                    .padding(.top, .space12)

                Text(verbatim: detail.activityCaption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space12)
                    .padding(.bottom, .space16)

                SectionHeader(title: "WHEN IT IS USED", topPadding: 12)

                UsageGrid(usage: detail.usage)
                    .padding(.top, .space12)

                Text(verbatim: detail.usageCaption)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.top, .space12)
                    .padding(.bottom, .space16)
            }
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }

    private func subtitle(_ summary: DeviceSummary) -> some View {
        Text(verbatim: "\(summary.modelName) · \(summary.osVersion) · seen \(summary.lastSeen.relativeString)")
            .font(.scoutRow)
            .foregroundStyle(Color.textMuted)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stats(_ detail: DeviceDetail) -> some View {
        HStack(spacing: 0) {
            stat("crashes", value: detail.crashes, color: .crashText, divider: true, leading: 0, trailing: 10)
            stat("hangs", value: detail.hangs, color: .hangText, divider: true, leading: 10, trailing: 10)
            stat("resources", value: detail.resources, color: .resourceText, divider: false, leading: 10, trailing: 0)
        }
        .overlay(alignment: .bottom) {
            Separator()
        }
    }

    private func stat(_ title: String, value: Int, color: Color, divider: Bool, leading: CGFloat, trailing: CGFloat) -> some View {
        StatColumn(title: title, leading: leading, trailing: trailing, divider: divider) {
            Text(verbatim: "\(value)")
                .font(.scoutNumberL)
                .monospacedDigit()
                .foregroundStyle(value > 0 ? color : Color.textPrimary)
        }
    }

    @ViewBuilder
    private func sessionRow(_ session: DeviceSession, deviceID: UUID, maxDuration: TimeInterval) -> some View {
        if let sessionID = session.sessionID {
            NavigationLink {
                SessionInspector(sessionID: sessionID, deviceID: deviceID)
            } label: {
                SessionLine(session: session, maxDuration: maxDuration)
            }
            .buttonStyle(.plain)
        } else {
            SessionLine(session: session, maxDuration: maxDuration)
        }
    }

    private func spacer(_ height: CGFloat) -> some View {
        Color.clear
            .frame(height: height)
    }
}

struct StatColumn<Value: View>: View {
    let title: String
    let leading: CGFloat
    let trailing: CGFloat
    var divider = true

    @ViewBuilder let value: () -> Value

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            value()

            Text(verbatim: title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.vertical, .space12)
        .padding(.leading, leading)
        .padding(.trailing, trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if divider {
                Separator(axis: .vertical)
            }
        }
    }
}

private struct SessionLine: View {
    let session: DeviceSession
    let maxDuration: TimeInterval

    var body: some View {
        HStack(spacing: .space8) {
            Circle()
                .fill(session.crashed ? Color.textDanger : Color.clear)
                .frame(width: 8, height: 8)

            Text(verbatim: session.time)
                .font(.scoutValue)
                .monospacedDigit()
                .lineLimit(1)
                .frame(width: 76, alignment: .leading)

            BarValue(text: session.durationText ?? "—", fraction: share, color: .deviceTrack)

            Text(verbatim: session.appVersion ?? "—")
                .font(.scoutCode)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .lineLimit(1)
                .frame(width: 44, alignment: .trailing)
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }

    private var share: Double {
        guard let duration = session.duration, maxDuration > 0 else {
            return 0
        }
        return duration / maxDuration
    }
}

private struct HistoryRow: View {
    let event: DeviceHistoryEvent
    let isLast: Bool

    var body: some View {
        HStack(spacing: .space12) {
            ZStack {
                if !isLast {
                    Rectangle()
                        .fill(Color.surfaceBarIdle)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .offset(y: 22)
                }

                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 8, height: 44)

            Text(verbatim: event.dateText)
                .font(.scoutValue)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .frame(width: 56, alignment: .leading)

            (Text(verbatim: event.title)
                + Text(verbatim: event.version.map { " " + $0 } ?? "")
                .font(.scoutValueStrong))
                .font(.scoutRow)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .lineLimit(1)
        .frame(height: .rowRegular)
    }

    private var color: Color {
        switch event.kind {
        case .installed, .reinstalled:
            .deviceAccent
        case .updated:
            .fillAccent
        case .os:
            Color.fillLevel
        }
    }
}

private struct DeviceActivityChart: View {
    let points: [DeviceActivityPoint]
    let showsCounts: Bool

    var body: some View {
        let maxCount = points.map(\.count).max() ?? 0

        HStack(alignment: .bottom, spacing: .space6) {
            ForEach(points) { point in
                VStack(spacing: .space4) {
                    if showsCounts {
                        Text(verbatim: point.count > 0 ? "\(point.count)" : "—")
                            .font(.scoutAxis)
                            .monospacedDigit()
                            .foregroundStyle(point.count > 0 ? Color.fillLevel : Color.pending)
                            .lineLimit(1)
                    }

                    VStack {
                        Spacer(minLength: 0)
                        RoundedRectangle(cornerRadius: .radiusBlock)
                            .fill(color(for: point))
                            .frame(height: height(for: point, maxCount: maxCount))
                    }
                    .frame(height: 56)

                    Text(verbatim: point.showsLabel ? point.label : "")
                        .font(point.isCurrent ? .system(size: 10, weight: .semibold) : .book(size: 10))
                        .foregroundStyle(point.isCurrent ? Color.textPrimary : Color.fillLevel)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Sessions per period"))
    }

    private func height(for point: DeviceActivityPoint, maxCount: Int) -> CGFloat {
        guard maxCount > 0, point.count > 0 else {
            return 1
        }
        return max(2, 56 * CGFloat(point.count) / CGFloat(maxCount))
    }

    private func color(for point: DeviceActivityPoint) -> Color {
        guard point.count > 0 else {
            return Color.surfaceSkeleton
        }
        return point.isCurrent ? .deviceAccent : .deviceAccentSoft
    }
}

private struct UsageGrid: View {
    let usage: DeviceUsage

    private let labels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: .space2) {
            ForEach(0..<7, id: \.self) { day in
                HStack(spacing: .space6) {
                    Text(verbatim: labels[day])
                        .font(.book(size: 10))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 10, alignment: .leading)

                    HStack(spacing: .space2) {
                        ForEach(0..<24, id: \.self) { hour in
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(color(day: day, hour: hour))
                                .frame(height: 12)
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                Text(verbatim: "00")
                Spacer()
                Text(verbatim: "06")
                Spacer()
                Text(verbatim: "12")
                Spacer()
                Text(verbatim: "18")
                Spacer()
                Text(verbatim: "23")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .padding(.leading, .gutter)
            .padding(.top, .space2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Sessions by weekday and hour"))
    }

    private func color(day: Int, hour: Int) -> Color {
        let count = usage.counts[day][hour]
        guard count > 0, usage.maxCount > 0 else {
            return .deviceShade
        }

        let share = Double(count) / Double(usage.maxCount)
        if share > 0.66 {
            return .deviceAccent
        }
        if share > 0.33 {
            return .deviceAccentSoft
        }
        return .deviceTrack
    }
}

#Preview("Device") {
    NavigationStack {
        DeviceDetailView(
            device: DeviceSummary.samples[0],
            provider: .init(.success(.sample), device: DeviceSummary.samples[0])
        )
    }
}

#Preview("Device loading") {
    NavigationStack {
        DeviceDetailPlaceholder(summary: DeviceSummary.samples[0], range: .constant(.week))
    }
}
