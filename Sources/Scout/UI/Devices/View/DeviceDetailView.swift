//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DeviceDetailView: View {
    let device: DeviceSummary

    var body: some View {
        List {
            FlowLayout(spacing: 6) {
                InfoChip(systemImage: device.model.hasPrefix("iPad") ? "ipad" : "iphone", text: device.model, color: .blue, monospaced: true)
                InfoChip(systemImage: "gearshape", text: device.osVersion, color: .indigo)
                InfoChip(systemImage: "clock", text: "seen \(device.lastSeen.relativeString)", color: .teal)
            }
            .listRowSeparator(.hidden)

            HStack(spacing: 28) {
                Metric(title: "Sessions", value: device.sessions.plain, color: .primary)
                Metric(title: "Crashes", value: device.crashes.plain, color: device.crashes > 0 ? .red : .primary)
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(en: device.model)
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(device: DeviceSummary.samples[0])
    }
}
