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
            Text(verbatim: title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .listRowSeparator(.hidden)

            NetworkEndpointHeaderPlaceholder()
                .listRowSeparator(.hidden)

            NetworkLedgerHeader(primary: primary)
                .listRowSeparator(.hidden)

            ForEach(0..<14, id: \.self) { index in
                NetworkLedgerRowPlaceholder(index: index, showsDivider: index < 13)
                    .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}
