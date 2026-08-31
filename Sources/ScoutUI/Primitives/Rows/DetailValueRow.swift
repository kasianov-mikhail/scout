//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct DetailValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(verbatim: title)
            Spacer()
            Text(verbatim: value)
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    InsetList {
        Header(title: "Section Title")
        DetailValueRow(title: "Latency", value: "148 ms")
        DetailValueRow(title: "Last Checked", value: "2m ago")
    }
}
