//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DevicesListView: View {
    let devices: [DeviceSummary]

    var body: some View {
        Group {
            if devices.isEmpty {
                Placeholder(
                    text: "No devices",
                    systemImage: "iphone.gen3",
                    description: "Devices appear here once your app reports sessions"
                )
            } else {
                List {
                    ForEach(devices.sorted { $0.lastSeen > $1.lastSeen }) { device in
                        DeviceLink(device: device)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(en: "Devices")
    }
}

#Preview("Devices — List") {
    NavigationStack {
        DevicesListView(devices: DeviceSummary.samples)
    }
}

#Preview("Devices — List Empty") {
    NavigationStack {
        DevicesListView(devices: [])
    }
}
