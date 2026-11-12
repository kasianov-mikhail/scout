//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// The Scout design-system spacing, radius, size and line tokens.
extension CGFloat {
    // MARK: - Space

    static let space2: CGFloat = 2
    static let space4: CGFloat = 4
    static let space6: CGFloat = 6
    static let space8: CGFloat = 8
    static let space10: CGFloat = 10
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space18: CGFloat = 18
    static let space20: CGFloat = 20
    static let space22: CGFloat = 22
    static let space24: CGFloat = 24

    /// The side inset of every iPhone screen.
    static let gutter: CGFloat = 16

    // MARK: - Radius

    /// Chart bars and rules.
    static let radiusBar: CGFloat = 2
    /// Blocks, skeletons, selection and tiles.
    static let radiusBlock: CGFloat = 3
    /// Badges and icon tiles.
    static let radiusBadge: CGFloat = 4
    /// Circles and the tag capsule.
    static let radiusRound: CGFloat = 999

    // MARK: - Size

    static let sectionHeaderHeight: CGFloat = 56
    static let navbarHeight: CGFloat = 106
    static let touchTarget: CGFloat = 44
    static let controlHeight: CGFloat = 40
    static let buttonHeight: CGFloat = 50

    // MARK: - Line

    static let hairline: CGFloat = 0.5
    static let ruleThick: CGFloat = 2
    static let iconStroke: CGFloat = 1.6
    static let iconStrokeBold: CGFloat = 2
    static let iconStrokeChevron: CGFloat = 2.4
}
