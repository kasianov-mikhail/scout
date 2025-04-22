//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A view that represents a row in a list, containing a navigation link to a destination view.
///
/// This view is designed to be used within a `List` and provides a way to navigate to
/// a destination view when the row is tapped. It uses a `ZStack` to overlay the content
/// and the navigation link, ensuring that the navigation link is always present but not visible.
///
/// - Parameters:
///  - content: A closure that returns the content view for the row.
///  - destination: A closure that returns the view to navigate to when the row is tapped.
///
struct Row<Content: View, Destination: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var destination: () -> Destination

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
