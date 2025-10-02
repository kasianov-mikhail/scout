//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsView: View {
    let title: String

    @State private var model = StatModel(period: Period.month)

    var body: some View {
        VStack(spacing: 0) {
            List {
                ChartView(points: .sample, model: model)
                    .foregroundStyle(.blue)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollDisabled(true)
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        MetricsView(title: "Matrices")
    }
}
