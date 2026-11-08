//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DevicesView: View {
    @StateObject var provider = DeviceModelsProvider()

    @Environment(\.database) private var database

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                DeviceListPlaceholder(range: $provider.range)
                    .transition(.opacity)
            case .success(let models):
                content(models)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: "Devices")
        .inlineNavigationTitle()
        .task(id: provider.range) {
            await provider.load(in: database)
        }
    }

    @ViewBuilder
    private func content(_ models: [DeviceModelSummary]) -> some View {
        if models.isEmpty {
            VStack(spacing: 0) {
                RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)

                Placeholder(
                    text: "No devices",
                    systemImage: "iphone.gen3",
                    description: "Devices appear here once your app reports sessions"
                )
            }
        } else {
            let maxSessions = models.map(\.sessions).max() ?? 0

            InsetList {
                RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)

                summary(models)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                    .listRowSeparator(.hidden)

                columns
                    .columnHeaderStyle()
                    .listRowSeparator(.hidden)

                ForEach(models) { model in
                    Row {
                        DeviceModelRow(model: model, maxSessions: maxSessions)
                    } destination: {
                        ModelDetailView(
                            model: model.model,
                            range: provider.range,
                            activities: provider.activitiesRange == provider.range
                                ? provider.activities.filter { $0.model == model.model }
                                : nil
                        )
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .exportToolbar(text: DevicesExport(models: models).text)
        }
    }

    private func summary(_ models: [DeviceModelSummary]) -> some View {
        let devices = models.map(\.devices).reduce(0, +)
        let crashing = models.filter { $0.crashes > 0 }.count

        return
            (Text(verbatim: "\(devices) \(devices == 1 ? "device" : "devices") in \(models.count) \(models.count == 1 ? "model" : "models") · ")
            + Text(verbatim: "\(crashing)").foregroundColor(crashing > 0 ? .crashText : Color(.systemGray))
            + Text(verbatim: " \(crashing == 1 ? "model" : "models") with crashes"))
            .font(.weight450(size: 15))
            .foregroundStyle(Color(.systemGray))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var columns: some View {
        HStack(spacing: 8) {
            ColumnHeader(title: "SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OS")
                .frame(width: 112, alignment: .leading)
            ColumnHeader(title: "CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
    }
}

private struct DeviceModelRow: View {
    let model: DeviceModelSummary
    let maxSessions: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: model.symbol)
                    .foregroundStyle(.blue)
                    .frame(width: 20)

                Text(verbatim: model.name)
                    .font(.weight450(size: 15))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(verbatim: "\(model.devices) \(model.devices == 1 ? "device" : "devices")")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                BarValue(text: model.sessions.compact, fraction: share, color: .deviceTrack)

                Text(verbatim: model.osLabel ?? "—")
                    .font(.weight450(size: 12, design: .monospaced))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
                    .frame(width: 112, alignment: .leading)

                Text(verbatim: model.crashes > 0 ? "\(model.crashes)" : "—")
                    .font(model.crashes > 0 ? .system(size: 13, weight: .bold, design: .monospaced) : .weight450(size: 13, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(model.crashes > 0 ? Color.crashText : Color.pending)
                    .frame(width: 56, alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }

    private var share: Double {
        maxSessions > 0 ? Double(model.sessions) / Double(maxSessions) : 0
    }
}

#Preview("Devices") {
    NavigationStack {
        DevicesView(provider: .init(.success(DeviceModelSummary.samples)))
    }
}

#Preview("Devices — Empty") {
    NavigationStack {
        DevicesView(provider: .init(.success([])))
    }
}

#Preview("Devices — Loading") {
    NavigationStack {
        DeviceListPlaceholder(range: .constant(.week))
            .navigationTitle(en: "Devices")
            .inlineNavigationTitle()
    }
}
