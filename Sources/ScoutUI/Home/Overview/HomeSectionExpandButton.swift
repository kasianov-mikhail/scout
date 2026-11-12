//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeSectionExpandButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up.right.and.arrow.down.left")
                .font(.book(size: 20))
                .frame(width: 44, height: 44)
                .padding(.trailing, -12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
        .accessibilityLabel(Text(verbatim: label))
    }
}

#Preview {
    HomeSectionExpandButton(label: "Show all active users") {}
        .padding()
}
