//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

/// A list footer that loads the next page when it appears.
///
struct PaginationFooter: View {
    let action: () async -> Void

    var body: some View {
        RingIndicator(size: 22)
            .task {
                await action()
            }
            .id(UUID())
            .frame(height: 68)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden, edges: .bottom)
    }
}
