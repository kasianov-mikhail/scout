//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension AnalyticsView {
    struct Suggestion: View {
        let text: String

        var body: some View {
            HStack {
                Text(text)
                    .font(.system(size: 17))
                    .monospaced()
                    .searchCompletion(text)
                    .foregroundStyle(.blue)
                Spacer()
            }
            .alignmentGuide(.listRowSeparatorTrailing) { dimension in
                dimension[.trailing]
            }
        }
    }
}

// MARK: - Unique Array Elements

extension Array {

    /// Returns an array of unique strings from the array, based on a specified key path
    /// and limited to a maximum number of elements.
    ///
    /// - Parameters:
    ///   - path: A key path to the property of the elements to be used for uniqueness.
    ///   - max: The maximum number of unique elements to return.
    /// - Returns: An array of unique strings, sorted by their frequency in descending order.
    ///
    func unique(by path: KeyPath<Element, String>, max: Int) -> [String] {
        let all = reduce(into: [:]) { dict, event in
            dict[event[keyPath: path]] = (dict[event[keyPath: path]] ?? 0) + 1
        }
        .sorted { lhs, rhs in
            lhs.value > rhs.value
        }
        .map(\.key)

        return [String](all.prefix(max))
    }
}
