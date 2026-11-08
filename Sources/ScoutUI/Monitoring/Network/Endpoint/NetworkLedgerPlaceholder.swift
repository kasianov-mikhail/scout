//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkLedgerPlaceholder: View {
    let title: String
    let primary: String

    var body: some View {
        InsetList {
            ListTitle(title: title)
                .frame(minHeight: 44)

            NetworkEndpointHeaderPlaceholder()
                .frame(minHeight: 44)

            NetworkLedgerHeader(primary: primary)
                .frame(minHeight: 44)

            ForEach(0..<14, id: \.self) { index in
                NetworkLedgerRowPlaceholder(index: index, showsDivider: index < 13)
                    .frame(minHeight: 44)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}
