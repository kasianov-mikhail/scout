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
            Image(systemName: "arrow.down.left.and.arrow.up.right")
                .font(.book(size: 16))
                .frame(width: 44, height: 44)
                .padding(.trailing, -12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.textLink)
        .accessibilityLabel(Text(verbatim: label))
    }
}

#Preview {
    HomeSectionExpandButton(label: "Show all active users") {}
        .padding()
}
