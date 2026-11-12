//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSectionEmpty: View {
    let onShowAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(title: "Releases") {
                HomeSectionExpandButton(label: "Show all releases", action: onShowAll)
            }

            HStack(alignment: .center, spacing: 8) {
                EmptyBar(width: 150, height: 26, cornerRadius: 4)

                Text(verbatim: "of sessions")
                    .font(.weight450(size: 15))
                    .foregroundStyle(Color(.systemGray))
            }
            .frame(height: 28)

            EmptyBar(height: 22, cornerRadius: 2)
                .padding(.top, 10)

            AdoptionLegend(squareSize: 7, squareColor: Color(.systemGray4), dashed: true)
                .padding(.top, 8)

            Text(verbatim: "No releases yet")
                .font(.weight450(size: 13))
                .foregroundStyle(Color(.systemGray))
                .padding(.top, 10)
                .padding(.bottom, 6)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HomeReleaseSectionEmpty {}
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}
