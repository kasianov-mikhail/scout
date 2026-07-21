//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension EdgeInsets {
    static let sideInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
}

struct PlainList<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        List {
            content().listRowInsets(.sideInsets)
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PlainList {
            Header(title: "Section Title")

            Row {
                Text(verbatim: "Label")
                Spacer()
                Text(verbatim: "Value")
            } destination: {
                Text(verbatim: "Detail")
            }

            Text(verbatim: "Full width")
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.1))
        }
    }
}
