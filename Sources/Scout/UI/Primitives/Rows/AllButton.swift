//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AllButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: "All".uppercased())
                .font(.callout.weight(.medium))
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        Header(title: "Section Title") {
            AllButton {}
        }
    }
    .listStyle(.plain)
}
