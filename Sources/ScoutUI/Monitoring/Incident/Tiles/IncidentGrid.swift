//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct IncidentGrid<Cell: View>: View {
    let count: Int
    @ViewBuilder let cell: (Int) -> Cell

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(alignment: .top, spacing: 0) {
                    positioned(row * 2, row: row)
                    positioned(row * 2 + 1, row: row)
                }
            }
        }
    }

    private var rows: Int {
        (count + 1) / 2
    }

    @ViewBuilder
    private func positioned(_ index: Int, row: Int) -> some View {
        if index < count {
            cell(index)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .overlay(alignment: .trailing) {
                    if index.isMultiple(of: 2), index + 1 < count {
                        separator(width: 0.5, height: nil)
                    }
                }
                .overlay(alignment: .bottom) {
                    if row < rows - 1 {
                        separator(width: nil, height: 0.5)
                    }
                }
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
        }
    }

    private func separator(width: CGFloat?, height: CGFloat?) -> some View {
        Rectangle()
            .fill(Color.separator)
            .frame(width: width, height: height)
            .allowsHitTesting(false)
    }
}
