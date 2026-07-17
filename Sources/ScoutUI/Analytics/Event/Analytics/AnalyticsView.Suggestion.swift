//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension AnalyticsView {
    struct Suggestion: View {
        let text: String

        var body: some View {
            HStack {
                Text(text)
                    .font(.body)
                    .monospaced()
                    .searchCompletion(text)
                    .foregroundStyle(.blue)
                Spacer()
            }
            .trailingRowSeparator()
        }
    }
}

extension Array {
    func unique(by path: KeyPath<Element, String>, max: Int) -> [String] {
        let all = reduce(into: [:]) { dict, event in
            dict[event[keyPath: path], default: 0] += 1
        }
        .sorted { lhs, rhs in
            lhs.value > rhs.value
        }
        .map(\.key)

        return [String](all.prefix(max))
    }
}
