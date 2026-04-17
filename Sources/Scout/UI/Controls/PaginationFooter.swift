//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

/// A list footer that loads the next page when it appears.
///
struct PaginationFooter: View {
    let cursor: CKQueryOperation.Cursor
    let action: (CKQueryOperation.Cursor) async -> Void

    var body: some View {
        ProgressView()
            .task {
                await action(cursor)
            }
            .id(UUID())
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden, edges: .bottom)
    }
}
