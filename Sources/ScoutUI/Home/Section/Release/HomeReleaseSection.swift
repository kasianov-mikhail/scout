//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeReleaseSection: View {
    @ObservedObject var releases: ReleaseHealthProvider

    @Binding var path: [HomeDestination]

    var body: some View {
        Header(title: "Releases") {
            if let releases = try? releases.result?.get(), releases.count > 0 {
                AllButton { path.append(.releaseHealth) }
            }
        }

        switch releases.result {
        case .success(let releases) where releases.count > 0:
            ForEach(releases.prefix(3)) { release in
                ReleaseRow(release: release)
            }

        case .success:
            Text(verbatim: "No results")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.gray.opacity(0.7))
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

        default:
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
                releases: ReleaseHealthProvider().holding(.samples),
                path: .constant([])
            )
            HomeReleaseSection(
                releases: ReleaseHealthProvider(releases: []),
                path: .constant([])
            )
        }
    }
}
