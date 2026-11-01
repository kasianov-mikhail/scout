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

extension Color {
    static var homePositive: Color {
        #if os(iOS)
            Color(
                uiColor: UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 48 / 255, green: 209 / 255, blue: 88 / 255, alpha: 1)
                        : UIColor(red: 36 / 255, green: 138 / 255, blue: 61 / 255, alpha: 1)
                }
            )
        #else
            Color(
                nsColor: NSColor(name: nil) { appearance in
                    appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                        ? NSColor(red: 48 / 255, green: 209 / 255, blue: 88 / 255, alpha: 1)
                        : NSColor(red: 36 / 255, green: 138 / 255, blue: 61 / 255, alpha: 1)
                }
            )
        #endif
    }

    static var homeInactiveValue: Color {
        #if os(iOS)
            Color(
                uiColor: UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1)
                        : UIColor(red: 108 / 255, green: 108 / 255, blue: 112 / 255, alpha: 1)
                }
            )
        #else
            Color(
                nsColor: NSColor(name: nil) { appearance in
                    appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                        ? NSColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1)
                        : NSColor(red: 108 / 255, green: 108 / 255, blue: 112 / 255, alpha: 1)
                }
            )
        #endif
    }
}
