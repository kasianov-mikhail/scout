//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatusDot: View {
    let status: Backend.Status

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 9, height: 9)
            .accessibilityLabel(Text(verbatim: status.label))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(Backend.Status.allCases) { status in
            HStack(spacing: 10) {
                StatusDot(status: status)
                Text(verbatim: status.label)
            }
        }
    }
    .padding()
}
