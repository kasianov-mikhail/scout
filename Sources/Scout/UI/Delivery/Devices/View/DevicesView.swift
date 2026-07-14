//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DevicesView: View {
    @StateObject var provider = DevicesProvider()
    @State private var showAllDevices = false

    var body: some View {
        ProviderView(provider: provider) { report in
            if report.summaries.count > 0 {
                content(report.summaries)
            } else {
                Placeholder(
                    text: "No devices",
                    systemImage: "iphone.gen3",
                    description: "Devices appear here once your app reports sessions"
                )
            }
        }
        .navigationTitle(en: "Devices")
    }

    private func content(_ devices: [DeviceSummary]) -> some View {
        let sorted = devices.sorted { $0.lastSeen > $1.lastSeen }
        let activeCutoff = Date(timeIntervalSinceNow: -7 * 86400)
        let activeCount = devices.filter { $0.lastSeen > activeCutoff }.count
        let crashingCount = devices.filter { $0.crashes > 0 }.count
        let modelBreakdown = IncidentBreakdown.segments(from: devices.map(\.modelName))
        let osBreakdown = IncidentBreakdown.segments(from: devices.map(\.osVersion))

        return List {
            HStack(spacing: 28) {
                Metric(title: "Devices", value: devices.count.plain, color: .primary)
                Metric(title: "Active 7d", value: activeCount.plain, color: .blue)
                Metric(title: "With Crashes", value: crashingCount.plain, color: crashingCount > 0 ? .red : .primary)
                Spacer()
            }
            .listRowSeparator(.hidden)

            Header(title: "Top Models")
            SegmentBar(segments: modelBreakdown).listRowSeparator(.hidden)

            Header(title: "OS Versions")
            SegmentBar(segments: osBreakdown).listRowSeparator(.hidden)

            Header(title: "Recent Devices") {
                AllButton { showAllDevices = true }
            }
            ForEach(sorted.prefix(3)) { device in
                DeviceLink(device: device)
            }
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: $showAllDevices) {
            DevicesListView(devices: devices)
        }
    }
}

#Preview("Devices") {
    let provider = DevicesProvider()
    provider.result = .success(.sample)

    return NavigationStack {
        DevicesView(provider: provider)
    }
}

#Preview("Devices — Empty") {
    let provider = DevicesProvider()
    provider.result = .success(.empty)

    return NavigationStack {
        DevicesView(provider: provider)
    }
}
