//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Row<Content: View, Destination: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        ZStack {
            HStack {
                content()
            }

            NavigationLink {
                destination()
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}
