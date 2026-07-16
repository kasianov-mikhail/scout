//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeRetentionSection: View {
    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Retention") {
            AllButton { path.append(.retention) }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            HomeRetentionSection(path: .constant([]))
        }
        .listStyle(.plain)
    }
}
