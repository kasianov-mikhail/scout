//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseGrid: View {
    let detail: ReleaseDetail

    var body: some View {
        let tiles = detail.tiles

        VStack(spacing: 0) {
            ForEach(0..<(tiles.count / 2), id: \.self) { index in
                HStack(spacing: 0) {
                    tile(tiles[index * 2], isLeading: true)
                    tile(tiles[index * 2 + 1], isLeading: false)
                }
            }
        }
        .padding(.horizontal, .gutter)
    }

    @ViewBuilder
    private func tile(_ value: ReleaseTileValue, isLeading: Bool) -> some View {
        if let destination = value.kind.destination {
            NavigationLink(value: destination) {
                ReleaseTile(value: value, isLeading: isLeading, action: nil)
            }
            .buttonStyle(.solid)
        } else {
            ReleaseTile(value: value, isLeading: isLeading, action: nil)
        }
    }
}
