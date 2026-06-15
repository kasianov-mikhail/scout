//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A small filled dot conveying a data source's reachability: green when
/// reachable, red when unreachable, grey when unknown.
///
struct StatusDot: View {
    let status: BackendStatus

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 9, height: 9)
            .accessibilityLabel(Text(verbatim: status.label))
    }
}

// MARK: - Previews

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(BackendStatus.allCases) { status in
            HStack(spacing: 10) {
                StatusDot(status: status)
                Text(verbatim: status.label)
            }
        }
    }
    .padding()
}
