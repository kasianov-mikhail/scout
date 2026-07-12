//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct DeviceDetailView: View {
    let device: DeviceSummary

    @StateObject private var incidents: DeviceIncidentsProvider
    @Environment(\.database) var database

    init(device: DeviceSummary, incidents: DeviceIncidentsProvider? = nil) {
        self.device = device
        self._incidents = StateObject(wrappedValue: incidents ?? DeviceIncidentsProvider(deviceID: device.id))
    }

    var body: some View {
        List {
            FlowLayout(spacing: 6) {
                InfoChip(systemImage: device.symbol, text: device.modelName, color: .blue)
                if device.modelName != device.model {
                    InfoChip(systemImage: "number", text: device.model, color: .gray, monospaced: true)
                }
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

            if crashes.count > 0 {
                Header(title: "Recent Crashes")
                ForEach(crashes) { crash in
                    Row {
                        if let date = crash.date {
                            UTCTimestampText(date: date, size: 14)
                        }
                        Spacer()
                        Text(verbatim: crash.name)
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    } destination: {
                        CrashDetailView(crash: crash)
                    }
                }
            }

            if hangs.count > 0 {
                Header(title: "Recent Hangs")
                ForEach(hangs) { hang in
                    Row {
                        if let date = hang.date {
                            UTCTimestampText(date: date, size: 14)
                        }
                        Spacer()
                        Text(verbatim: hang.durationText)
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    } destination: {
                        HangDetailView(hang: hang)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(en: device.modelName)
        .task {
            await incidents.fetchIfNeeded(in: database)
        }
    }

    private var crashes: [Crash] {
        (try? incidents.result?.get().crashes) ?? []
    }

    private var hangs: [Hang] {
        (try? incidents.result?.get().hangs) ?? []
    }
}

#Preview {
    let incidents = DeviceIncidentsProvider(deviceID: DeviceSummary.samples[0].id)
    incidents.result = .success(DeviceIncidents(crashes: Crash.samples, hangs: Hang.samples))

    return NavigationStack {
        DeviceDetailView(device: DeviceSummary.samples[0], incidents: incidents)
    }
}
