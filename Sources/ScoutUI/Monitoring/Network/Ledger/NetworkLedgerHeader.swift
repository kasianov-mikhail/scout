//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkEndpointListHeader: View {
    var body: some View {
        HStack(spacing: .space8) {
            ColumnHeader(title: "REQUESTS ↓", color: .networkAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OK")
                .frame(width: 56, alignment: .trailing)
            ColumnHeader(title: "P99")
                .frame(width: 64, alignment: .trailing)
        }
        .columnHeaderStyle()
    }
}

struct NetworkLedgerHeader: View {
    let primary: String

    var body: some View {
        HStack(spacing: .space8) {
            ColumnHeader(title: primary + " ↓", color: .networkAccent)
                .frame(width: 58, alignment: .leading)
            ColumnHeader(title: "REQUESTS")
                .frame(maxWidth: .infinity, alignment: .leading)
            ColumnHeader(title: "OK")
                .frame(width: 56, alignment: .trailing)
            ColumnHeader(title: "P99")
                .frame(width: 64, alignment: .trailing)
        }
        .columnHeaderStyle()
    }
}
