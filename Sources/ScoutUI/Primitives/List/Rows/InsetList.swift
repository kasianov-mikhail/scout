//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct InsetList<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        InsetList {
            Header(title: "Section Title")

            NavigationLink {
                Text(verbatim: "Detail")
            } label: {
                HStack(spacing: 8) {
                    Text(verbatim: "Label")
                    Spacer()
                    Text(verbatim: "Value")
                }
                .lineLimit(1)
                .frame(height: 44)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            Text(verbatim: "Full width")
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.1))
        }
    }
}
