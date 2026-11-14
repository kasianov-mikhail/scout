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
            if let error = provider.error {
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            } else if case .success(let models) = provider.result, models.isEmpty {
                VStack(spacing: 0) {
                    RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                        .padding(.top, .space8)
                        .padding(.horizontal, .gutter)

                    Placeholder(
                        text: "No devices",
                        systemImage: "iphone.gen3",
                        description: "Devices appear here once your app reports sessions"
                    )
                }
            } else {
                ScrollView {
                    if case .success(let models) = provider.result {
                        content(models)
                            .transition(.opacity)
                    } else {
                        DeviceListPlaceholder(range: $provider.range)
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: "Devices")
        .inlineNavigationTitle()
        .task(id: provider.range) {
            await provider.load(in: database)
        }
    }

    private func content(_ models: [DeviceModelSummary]) -> some View {
        let maxSessions = models.map(\.sessions).max() ?? 0

        return LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                .padding(.top, .space8)

            summary(models)
                .padding(.top, .space4)
                .padding(.bottom, .space12)
                .overlay(alignment: .bottom) {
                    Separator()
                }

            columns
                .columnHeaderStyle()

            ForEach(models) { model in
                NavigationLink {
                    ModelDetailView(
                        model: model.model,
                        range: provider.range,
                        activities: provider.activitiesRange == provider.range
                            ? provider.activities.filter { $0.model == model.model }
                            : nil
                    )
                } label: {
                    DeviceModelRow(model: model, maxSessions: maxSessions)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .gutter)
        .exportToolbar(text: DevicesExport(models: models).text)
    }

    private func summary(_ models: [DeviceModelSummary]) -> some View {
        let devices = models.map(\.devices).reduce(0, +)
        let crashing = models.filter { $0.crashes > 0 }.count

        return
            (Text(verbatim: "\(devices) \(devices == 1 ? "device" : "devices") in \(models.count) \(models.count == 1 ? "model" : "models") · ")
            + Text(verbatim: "\(crashing)").foregroundColor(crashing > 0 ? .crashText : Color.fillLevel)
            + Text(verbatim: " \(crashing == 1 ? "model" : "models") with crashes"))
            .font(.scoutRow)
            .foregroundStyle(Color.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var columns: some View {
        HStack(spacing: .space8) {
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
        VStack(alignment: .leading, spacing: .space8) {
            HStack(spacing: .space8) {
                Image(systemName: model.symbol)
                    .foregroundStyle(Color.textLink)
                    .frame(width: 20)

                Text(verbatim: model.name)
                    .font(.scoutRow)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(verbatim: "\(model.devices) \(model.devices == 1 ? "device" : "devices")")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
            }

            HStack(spacing: .space8) {
                BarValue(text: model.sessions.compact, fraction: share, color: .deviceTrack)

                Text(verbatim: model.osLabel ?? "—")
                    .font(.scoutCode)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
                    .frame(width: 112, alignment: .leading)

                Text(verbatim: model.crashes > 0 ? "\(model.crashes)" : "—")
                    .font(model.crashes > 0 ? .scoutValueStrong : .scoutValue)
                    .monospacedDigit()
                    .foregroundStyle(model.crashes > 0 ? Color.crashText : Color.pending)
                    .frame(width: 56, alignment: .trailing)
            }
        }
        .lineLimit(1)
        .frame(height: .rowChart)
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
        ScrollView {
            DeviceListPlaceholder(range: .constant(.week))
        }
        .scrollIndicators(.hidden)
        .navigationTitle(en: "Devices")
        .inlineNavigationTitle()
    }
}
