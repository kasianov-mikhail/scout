//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PeriodPicker: View {
    @Binding var selection: Period

    var body: some View {
        Picker(selection: $selection) {
            ForEach(Period.allCases) { period in
                Text(period.shortTitle.uppercased())
            }
        } label: {
            Text(verbatim: "Period")
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)
    }
}

#Preview {
    struct Preview: View {
        @State private var selection = Period.today

        var body: some View {
            PeriodPicker(selection: $selection)
        }
    }
    return Preview()
}
