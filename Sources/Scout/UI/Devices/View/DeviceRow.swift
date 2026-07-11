//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DeviceLink: View {
    let device: DeviceSummary

    var body: some View {
        Row {
            DeviceRow(device: device)
        } destination: {
            DeviceDetailView(device: device)
        }
    }
}

struct DeviceRow: View {
    let device: DeviceSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: device.symbol)
                .foregroundStyle(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: device.modelName)
                    .font(.subheadline.weight(.medium))
                Text(verbatim: device.osVersion + " · " + device.sessions.plain + " sessions")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            if device.crashes > 0 {
                CountBadge(count: device.crashes, prefix: "×")
            }

            Text(verbatim: device.lastSeen.relativeString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(minWidth: 64, alignment: .trailing)
        }
        .frame(height: 44)
    }
}

#Preview("DeviceRow") {
    List(DeviceSummary.samples) { device in
        DeviceRow(device: device)
    }
    .listStyle(.plain)
}
