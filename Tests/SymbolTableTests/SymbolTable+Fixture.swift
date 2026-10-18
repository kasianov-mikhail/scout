//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

@testable import SymbolTable

extension SymbolTable {
    static var sample: SymbolTable {
        SymbolTable(
            uuid: UUID(uuidString: "C8ED9CB2-606E-301A-A5F8-CAA01E39224F")!,
            functions: [
                Function(start: 0x1000, end: 0x1080, name: "CartViewModel.applyDiscount(_:)"),
                Function(start: 0x2000, end: 0x2100, name: "CartView.body.getter"),
            ],
            lines: [
                Line(address: 0x1000, location: Location(file: "CartViewModel.swift", line: 82)),
                Line(address: 0x1010, location: Location(file: "Price.swift", line: 30)),
                Line(address: 0x1040, location: Location(file: "CartViewModel.swift", line: 90)),
                Line(address: 0x1080, location: nil),
                Line(address: 0x2000, location: Location(file: "CartView.swift", line: 47)),
                Line(address: 0x2080, location: nil),
            ],
            inlines: [
                Inline(start: 0x1008, end: 0x1020, depth: 1, name: "Price.multiplied(by:)", call: Location(file: "CartViewModel.swift", line: 84)),
                Inline(start: 0x1010, end: 0x101C, depth: 2, name: "Price.rounded()", call: Location(file: "Price.swift", line: 21)),
            ]
        )
    }
}
