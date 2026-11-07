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
        .alignmentGuide(.listRowSeparatorTrailing) { $0[.trailing] }
    }
}

struct DashedLine: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0.25))
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0.25))
            }
            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
        }
        .frame(height: 0.5)
    }
}

#Preview {
    NavigationStack {
        InsetList {
            Row {
                Text(verbatim: "Label")
                Spacer()
                Text(verbatim: "Value")
            } destination: {
                Text(verbatim: "Detail")
            }
        }
    }
}
