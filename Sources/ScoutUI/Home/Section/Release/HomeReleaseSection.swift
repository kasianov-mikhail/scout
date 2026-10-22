//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeReleaseSection: View {
    @ObservedObject var releases: ReleaseHealthProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Releases") {
            switch releases.result {
            case .success(let releases) where !releases.isEmpty:
                AllButton { path.append(.releaseHealth) }
            case .success, .failure, nil:
                EmptyView()
            }
        }

        switch releases.result {
        case .success(let releases) where !releases.isEmpty:
            ForEach(releases.prefix(3)) { release in
                ReleaseRow(release: release)
            }

        case .success:
            Text(verbatim: "No results")
                .font(.body)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

        case .failure, nil:
            ForEach(0..<3, id: \.self) { _ in
                ReleaseRowPlaceholder()
            }
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeReleaseSection(
                releases: .init(.success(.samples)),
                path: .constant([])
            )
            HomeReleaseSection(
                releases: .init(.success([])),
                path: .constant([])
            )
        }
    }
}
