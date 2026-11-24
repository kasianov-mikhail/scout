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

                    SectionGap()
                        .padding(.top, .space8)

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
        .loadingInk(isLoading: provider.isLoading)
        .navigationTitle(en: "Devices")
        .inlineNavigationTitle(divider: nil)
        .task(id: provider.range) {
            await provider.load(in: database)
        }
    }

    private func content(_ models: [DeviceModelSummary]) -> some View {
        let maxSessions = models.map(\.sessions).max() ?? 0

        return LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $provider.range, ranges: IncidentRange.allCases, title: \.title)
                .padding(.horizontal, -.gutter)

            summary(models)
                .padding(.top, .space4)
                .padding(.bottom, .space12)

            SectionGap()
                .padding(.horizontal, -.gutter)

            columns
                .columnHeaderStyle(topPadding: 12)

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
                .buttonStyle(.solid)
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
        .inlineNavigationTitle(divider: nil)
    }
}
