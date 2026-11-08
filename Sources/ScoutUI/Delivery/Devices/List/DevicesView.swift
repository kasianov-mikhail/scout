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
                IncidentRangeStrip(selection: $provider.range)
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
                IncidentRangeStrip(selection: $provider.range)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)

                summary(models)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .overlay(alignment: .bottom) {
                        separator
                    }
                    .listRowSeparator(.hidden)

                columns
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .overlay(alignment: .bottom) {
                        separator
                    }
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
            .font(.system(size: 15))
            .foregroundStyle(Color(.systemGray))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var columns: some View {
        HStack(spacing: 8) {
            column("SESSIONS")
                .frame(maxWidth: .infinity, alignment: .leading)
            column("OS")
                .frame(width: 112, alignment: .leading)
            column("CRASHES")
                .frame(width: 56, alignment: .trailing)
        }
        .foregroundStyle(Color(.systemGray))
    }

    private func column(_ title: String) -> some View {
        Text(verbatim: title)
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.3)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.separator)
            .frame(height: 0.5)
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
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(verbatim: "\(model.devices) \(model.devices == 1 ? "device" : "devices")")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                Text(verbatim: model.sessions.compact)
                    .font(.system(size: 13, design: .monospaced))
                    .monospacedDigit()
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(alignment: .leading) {
                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.deviceTrack)
                                .frame(width: proxy.size.width * share)
                        }
                    }

                Text(verbatim: model.osLabel ?? "—")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
                    .frame(width: 112, alignment: .leading)

                Text(verbatim: model.crashes > 0 ? "\(model.crashes)" : "—")
                    .font(.system(size: 13, weight: model.crashes > 0 ? .bold : .regular, design: .monospaced))
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

    private var share: CGFloat {
        maxSessions > 0 ? CGFloat(model.sessions) / CGFloat(maxSessions) : 0
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
