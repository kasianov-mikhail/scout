//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct FilterButton: View {
    @Binding var query: EventQuery

    @State private var isFilterPresented = false

    var body: some View {
        Button {
            isFilterPresented = true
        } label: {
            Text(verbatim: "Filter")
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterView(query: $query)
                .opaquePresentation()
        }
        .tint(.primary)
    }
}

#Preview {
    FilterButton(query: .constant(EventQuery()))
}
