//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutCore
import SwiftUI

struct ChartExportButton<ChartContent: View>: View {
    let title: String
    let rangeLabel: String

    @ViewBuilder let chart: () -> ChartContent

    @State private var isExporting = false

    var body: some View {
        Button {
            isExporting = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $isExporting) {
            NavigationStack {
                ChartExportSheet(title: title, rangeLabel: rangeLabel, chart: chart)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text(verbatim: "Content")
            .navigationTitle(en: "Chart Export Button")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ChartExportButton(title: "app_launch", rangeLabel: "Jun 2 – Jul 2, 2026") {
                        ChartView(segment: .sample, timing: ChartExtent(period: Period.month))
                    }
                }
            }
    }
}
