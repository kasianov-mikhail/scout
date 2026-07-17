//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

/// List row with the switch that turns the previous-period overlay on.
struct ComparisonToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(verbatim: "Compare with previous period")
        }
        .listRowSeparator(.hidden)
        .hapticFeedback(.selection, trigger: isOn)
    }
}

#Preview("ComparisonToggle") {
    List {
        ComparisonToggle(isOn: .constant(true))
        ComparisonToggle(isOn: .constant(false))
        ComparisonToggle(isOn: .constant(false))
            .disabled(true)
    }
    .listStyle(.plain)
}
