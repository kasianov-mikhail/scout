//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct NetworkStatusRow: View {
    let item: NetworkStatusClass
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(item.color)
                .frame(width: 8, height: 8)
                .frame(width: 14, alignment: .leading)

            Text(verbatim: item.label)
                .font(.weighted(size: 13, weight: item.isFailure ? .semibold : .regular, design: .monospaced))
                .foregroundStyle(item.labelColor)
                .frame(width: 44, alignment: .leading)

            Text(verbatim: item.count.compact)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: item.percent(total: total))
                .foregroundStyle(Color(.systemGray))
                .frame(width: 56, alignment: .trailing)
        }
        .font(.weight450(size: 13, design: .monospaced))
        .frame(height: 40)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
    }
}

struct NetworkStatusClass: Identifiable {
    let index: Int
    let label: String
    let count: Int
    let color: Color
    let labelColor: Color

    var id: Int { index }

    var isFailure: Bool {
        index >= 2
    }

    func percent(total: Int) -> String {
        guard total > 0 else {
            return "0.0%"
        }
        return String(format: "%.1f%%", Double(count) / Double(total) * 100)
    }
}

extension StatusBreakdown {
    var networkClasses: [NetworkStatusClass] {
        let colors: [(Color, Color)] = [
            (.networkTrack, .primary),
            (.networkRedirect, .primary),
            (.networkClient, .networkWarning),
            (.networkServer, .networkCritical),
        ]

        return zip(StatusBuckets.classes, counts).enumerated().compactMap { index, pair in
            guard pair.1 > 0 else {
                return nil
            }
            return NetworkStatusClass(
                index: index,
                label: pair.0,
                count: pair.1,
                color: colors[index].0,
                labelColor: colors[index].1
            )
        }
    }
}
