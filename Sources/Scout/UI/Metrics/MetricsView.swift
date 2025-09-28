//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsView: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.largeTitle)
            .bold()
            .navigationTitle(title)
    }
}

#Preview {
    MetricsView(title: "Metrics")
}
