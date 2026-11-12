//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct MetricsListView: View {
    @StateObject var provider = MetricsListProvider()

    @Environment(\.database) private var database

    var body: some View {
        Group {
            switch provider.result {
            case nil:
                MetricsListPlaceholder(range: $provider.range)
                    .transition(.opacity)
            case .success(let tiles):
                content(tiles)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(verbatim: error.localizedDescription)) {
                    await provider.load(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .navigationTitle(en: "Metrics")
        .inlineNavigationTitle()
        .task(id: provider.range) {
            await provider.load(in: database)
        }
    }

    @ViewBuilder
    private func content(_ tiles: [MetricTile]) -> some View {
        if tiles.isEmpty {
            VStack(spacing: 0) {
                MetricRangeStrip(selection: $provider.range)
                    .padding(.top, 8)
                    .padding(.leading, 16)

                Placeholder(
                    text: "No metrics",
                    systemImage: "chart.bar",
                    description: "Metrics appear here once your app records data",
                    code: """
                        Counter(label: "api_calls")
                            .increment()
                        """
                )
            }
        } else {
            InsetList {
                MetricRangeStrip(selection: $provider.range)
                    .padding(.top, 8)
                    .padding(.trailing, -16)

                grid(tiles)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.separator)
                            .frame(height: 0.5)
                    }
            }
        }
    }

    private func grid(_ tiles: [MetricTile]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(stride(from: 0, to: tiles.count, by: 2)), id: \.self) { index in
                HStack(spacing: 0) {
                    tile(tiles[index], isLeading: true)

                    if index + 1 < tiles.count {
                        tile(tiles[index + 1], isLeading: false)
                    }
                }
            }
        }
    }

    private func tile(_ tile: MetricTile, isLeading: Bool) -> some View {
        NavigationLink {
            MetricDetailView(name: tile.name, telemetry: tile.telemetry, range: provider.range)
        } label: {
            MetricTileView(tile: tile, isLeading: isLeading)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Metrics") {
    NavigationStack {
        MetricsListView(provider: MetricsListProvider(.success(MetricTile.samples)))
    }
}

#Preview("Metrics loading") {
    NavigationStack {
        MetricsListView(provider: MetricsListProvider())
    }
}

#Preview("Metrics empty") {
    NavigationStack {
        MetricsListView(provider: MetricsListProvider(.success([])))
    }
}
