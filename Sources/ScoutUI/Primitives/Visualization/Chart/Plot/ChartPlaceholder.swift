//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ChartPlaceholder: View {
    var body: some View {
        Text(verbatim: "No results")
            .font(.placeholderTitle)
            .foregroundStyle(.gray.opacity(0.7))
    }
}
