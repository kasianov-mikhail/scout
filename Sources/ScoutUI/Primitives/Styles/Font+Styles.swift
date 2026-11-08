//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

extension Font {
    static let placeholderTitle = Font.system(size: 18, weight: .semibold)
    static let codeChip = Font.system(size: 14, design: .monospaced)
    static let listTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let telemetryTitle = Font.system(size: 16, variableWeight: 0.12)
    static let telemetryCaption = Font.system(size: 13, variableWeight: 0.12)

    static func system(size: CGFloat, variableWeight: CGFloat) -> Font {
        #if os(iOS)
            Font(UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: variableWeight)))
        #else
            Font(NSFont.systemFont(ofSize: size, weight: NSFont.Weight(rawValue: variableWeight)))
        #endif
    }
}
