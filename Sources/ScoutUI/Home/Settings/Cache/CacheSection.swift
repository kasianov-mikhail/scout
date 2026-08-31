//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct CacheSection: View {
    @StateObject private var cache: CacheStatus

    @State private var isClearing = false

    init(bytes: Int64) {
        _cache = StateObject(wrappedValue: CacheStatus(bytes: bytes))
    }

    var body: some View {
        Header(title: "Cache")

        DetailValueRow(title: "Cached Data", value: cache.sizeLabel)

        Button(role: .destructive) {
            isClearing = true
        } label: {
            Text(verbatim: "Clear Cache")
        }
        .disabled(cache.isEmpty)
        .confirmationDialog(
            Text(verbatim: "Clear the cached data?"),
            isPresented: $isClearing,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                cache.clear()
            } label: {
                Text(verbatim: "Clear Cache")
            }
        } message: {
            Text(verbatim: "Charts and lists will reload from the backend on their next refresh.")
        }
    }
}

#Preview("Populated") {
    InsetList {
        CacheSection(bytes: 12_582_912)
    }
}

#Preview("Empty") {
    InsetList {
        CacheSection(bytes: 0)
    }
}
