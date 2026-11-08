//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkEndpointListHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: "REQUESTS ↓")
                .networkColumnHeader()
                .foregroundColor(Color.networkAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(verbatim: "OK")
                .networkColumnHeader()
                .hidden()
                .frame(width: 56, alignment: .trailing)
            Text(verbatim: "P99")
                .networkColumnHeader()
                .hidden()
                .frame(width: 64, alignment: .trailing)
        }
        .networkColumnHeaderStyle()
    }
}

struct NetworkLedgerHeader: View {
    let primary: String

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: primary + " ↓")
                .networkColumnHeader()
                .foregroundColor(Color.networkAccent)
                .frame(width: 58, alignment: .leading)
            Text(verbatim: "REQUESTS")
                .networkColumnHeader()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(verbatim: "OK")
                .networkColumnHeader()
                .frame(width: 56, alignment: .trailing)
            Text(verbatim: "P99")
                .networkColumnHeader()
                .frame(width: 64, alignment: .trailing)
        }
        .networkColumnHeaderStyle()
    }
}

struct NetworkSectionHeader: View {
    let title: String

    var body: some View {
        Text(verbatim: title)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 56)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
    }
}

extension Text {
    fileprivate func networkColumnHeader() -> Text {
        font(.system(size: 11, weight: .semibold))
            .tracking(0.3)
    }
}

extension View {
    fileprivate func networkColumnHeaderStyle() -> some View {
        foregroundStyle(Color(.systemGray))
            .padding(.top, 14)
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
    }
}
