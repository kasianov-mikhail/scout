//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DevicesListView: View {
    let devices: [DeviceSummary]

    @State private var message: Message?

    var body: some View {
        Group {
            if devices.isEmpty {
                Placeholder(
                    text: "No devices",
                    systemImage: "iphone.gen3",
                    description: "Devices appear here once your app reports sessions"
                )
            } else {
                InsetList {
                    ForEach(devices.sorted { $0.lastSeen > $1.lastSeen }) { device in
                        DeviceLink(device: device)
                    }
                }
            }
        }
        .navigationTitle(en: "Devices")
        .toolbar {
            if let text = DevicesExport(devices: devices).text {
                ToolbarItemGroup(placement: .bottomBar) {
                    ShareLink(item: text)
                    CopyButton(text: text, message: $message)
                    Spacer()
                }
            }
        }
        .message($message)
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
