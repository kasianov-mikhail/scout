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

            Row {
                Text(verbatim: "Label")
                Spacer()
                Text(verbatim: "Value")
            } destination: {
                Text(verbatim: "Detail")
            }

            Text(verbatim: "Full width")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .background(.blue.opacity(0.1))
        }
    }
}
