//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

private struct ConceptAlert: Identifiable {
    let id = UUID()
    let color: Color
    let title: String
    let detail: String
    let time: String
    let values: [Int]
}

extension ConceptAlert {
    static let crashFree = ConceptAlert(
        color: .red,
        title: "Crash-free sessions",
        detail: "98.2% — below 99.5% for 2h",
        time: "14:20",
        values: [12, 11, 12, 10, 8, 6, 5]
    )

    static let latency = ConceptAlert(
        color: .orange,
        title: "POST /v1/records p99",
        detail: "412 ms — 2.3× above baseline",
        time: "11:05",
        values: [3, 3, 4, 3, 5, 9, 14]
    )

    static let errors = ConceptAlert(
        color: .orange,
        title: "Error logs",
        detail: "148/h — spike over 3× median",
        time: "21:47",
        values: [2, 3, 2, 2, 3, 11, 4]
    )

    static let adoption = ConceptAlert(
        color: .blue,
        title: "Release 3.4.0 adoption",
        detail: "Reached 50% of sessions",
        time: "09:30",
        values: [1, 2, 4, 7, 11, 14, 16]
    )
}

private struct AlertInboxRow: View {
    let alert: ConceptAlert

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(alert.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: alert.title)
                    .font(.body.weight(.medium))
                Text(verbatim: alert.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(verbatim: alert.time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                MiniChart(series: MiniChartSeries(values: alert.values), color: alert.color)
            }
        }
        .padding(.vertical, 4)
        .trailingRowSeparator()
    }
}

#Preview("1 · Inbox — лента алертов") {
    NavigationStack {
        List {
            Header(title: "Today")
            AlertInboxRow(alert: .crashFree)
            AlertInboxRow(alert: .latency)
            Header(title: "Yesterday")
            AlertInboxRow(alert: .errors)
            AlertInboxRow(alert: .adoption)
        }
        .listStyle(.plain)
        .navigationTitle(en: "Alerts")
    }
}

private struct ThresholdChartConcept: View {
    let values: [Double] = [99.8, 99.7, 99.8, 99.6, 99.4, 98.9, 98.2]
    let threshold = 99.5

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "CRASH-FREE SESSIONS")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(verbatim: "98.2%")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Label("Fired 14:20", systemImage: "bell.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                    Text(verbatim: "below 99.5% for 2h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Chart {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    AreaMark(x: .value("Hour", index), yStart: .value("Bottom", 98.0), yEnd: .value("Value", value))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red.opacity(0.25), .red.opacity(0.03)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    LineMark(x: .value("Hour", index), y: .value("Value", value))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                }

                RuleMark(y: .value("Threshold", threshold))
                    .foregroundStyle(.red.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .topTrailing) {
                        Text(verbatim: "99.5%")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.red)
                    }

                PointMark(x: .value("Hour", 5), y: .value("Value", 98.9))
                    .foregroundStyle(.red)
                    .symbolSize(80)
            }
            .chartYScale(domain: 98.0...100.0)
            .chartXAxis(.hidden)
            .frame(height: 180)

            HStack(spacing: 12) {
                Button {
                } label: {
                    Text(verbatim: "Open Sessions")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                } label: {
                    Text(verbatim: "Mute 24h")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

#Preview("3 · Threshold — график с порогом") {
    ThresholdChartConcept()
}

private struct AlertBanner: View {
    let alert: ConceptAlert

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(alert.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: alert.title)
                    .font(.subheadline.weight(.semibold))
                Text(verbatim: alert.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            MiniChart(series: MiniChartSeries(values: alert.values), color: alert.color)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(alert.color.opacity(0.12))
        .background()
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(alert.color.opacity(0.6), lineWidth: 1)
        }
        .padding(.horizontal)
    }
}

#Preview("5 · Banner — richer in-app тост") {
    VStack(spacing: 12) {
        AlertBanner(alert: .crashFree)
        AlertBanner(alert: .latency)
        AlertBanner(alert: .adoption)
    }
}

private struct StatusChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(color.opacity(0.12), in: Capsule())
    }
}

private struct StatusStripConcept: View {
    var body: some View {
        NavigationStack {
            List {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        StatusChip(icon: "exclamationmark.triangle.fill", text: "Crash-free 98.2%", color: .red)
                        StatusChip(icon: "clock.fill", text: "p99 ×2.3", color: .orange)
                        StatusChip(icon: "checkmark.circle.fill", text: "Errors OK", color: .green)
                        StatusChip(icon: "checkmark.circle.fill", text: "Sessions OK", color: .green)
                    }
                }
                .listRowSeparator(.hidden)

                Header(title: "Alerts") {
                    Text(verbatim: "2")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                }
                AlertInboxRow(alert: .crashFree)
                AlertInboxRow(alert: .latency)

                Header(title: "Metrics")
                HStack {
                    Text(verbatim: "Sessions")
                    Spacer()
                    MiniChart(series: MiniChartSeries(values: [7, 8, 8, 9, 8, 9, 10]), color: .purple)
                }
                .trailingRowSeparator()
            }
            .listStyle(.plain)
            .navigationTitle(en: "Scout")
        }
    }
}

#Preview("7 · Status Strip — статус на Home") {
    StatusStripConcept()
}
