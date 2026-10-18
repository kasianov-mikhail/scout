//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension SymbolTable {
    package func frames(offset: UInt64) -> [Frame] {
        let index = functions.boundary { $0.start <= offset } - 1
        guard functions.indices.contains(index) else {
            return []
        }
        let function = functions[index]
        guard offset < function.end else {
            return []
        }

        let chain = inlineChain(function: function, offset: offset)
        let names = [function.name] + chain.map(\.name)
        let locations = chain.map(\.call) + [location(offset: offset)]

        return zip(names, locations).map(Frame.init).reversed()
    }

    private func inlineChain(function: Function, offset: UInt64) -> [Inline] {
        let first = inlines.boundary { $0.start < function.start }
        return inlines[first...]
            .prefix { $0.start <= offset }
            .filter { offset < $0.end }
            .sorted { $0.depth < $1.depth }
    }

    private func location(offset: UInt64) -> Location? {
        let index = lines.boundary { $0.address <= offset } - 1
        return lines.indices.contains(index) ? lines[index].location : nil
    }
}

extension Array {
    fileprivate func boundary(isBefore: (Element) -> Bool) -> Int {
        var low = 0
        var high = count

        while low < high {
            let middle = (low + high) / 2
            if isBefore(self[middle]) {
                low = middle + 1
            } else {
                high = middle
            }
        }

        return low
    }
}
