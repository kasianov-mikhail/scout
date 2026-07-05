//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Font {
    static let placeholderTitle = Font.system(size: 18, weight: .semibold)
    static let codeChip = Font.system(size: 14, design: .monospaced)
    static let stepBadge = Font.system(size: 13, weight: .semibold)
}

// A fixed-size mirror of the built-in Dynamic Type scale: each style matches its
// semantic counterpart's size at the default content size but does not scale.
extension Font {
    static let fixedTitle = Font.system(size: 28)
    static let fixedTitle2 = Font.system(size: 22)
    static let fixedTitle3 = Font.system(size: 20)
    static let fixedHeadline = Font.system(size: 17, weight: .semibold)
    static let fixedBody = Font.system(size: 17)
    static let fixedCallout = Font.system(size: 16)
    static let fixedSubheadline = Font.system(size: 15)
    static let fixedFootnote = Font.system(size: 13)
    static let fixedCaption = Font.system(size: 12)
    static let fixedCaption2 = Font.system(size: 11)
}
