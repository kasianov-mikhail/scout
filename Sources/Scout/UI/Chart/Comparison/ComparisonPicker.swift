//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ComparisonPicker: View {
    @Binding var comparison: ChartComparison?

    var body: some View {
        Picker(selection: $comparison) {
            Text(verbatim: "Off").tag(ChartComparison?.none)
            ForEach(ChartComparison.allCases) { comparison in
                Text(verbatim: comparison.title).tag(ChartComparison?.some(comparison))
            }
        } label: {
            Text(verbatim: "Compare")
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

// MARK: - Previews

#Preview {
    ComparisonPicker(comparison: .constant(.overlay))
}
