//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Builds a color that resolves to the light value in a light appearance and to the dark value in a dark one.
func designColor(light: UInt32, dark: UInt32, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) -> Color {
    #if os(macOS)
        Color(
            nsColor: NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                return NSColor(hex: isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha)
            }
        )
    #else
        Color(
            uiColor: UIColor { traits in
                let isDark = traits.userInterfaceStyle == .dark
                return UIColor(hex: isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha)
            }
        )
    #endif
}

#if os(macOS)
    extension NSColor {
        convenience init(hex: UInt32, alpha: CGFloat = 1) {
            self.init(
                srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: alpha
            )
        }
    }
#else
    extension UIColor {
        convenience init(hex: UInt32, alpha: CGFloat = 1) {
            self.init(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: alpha
            )
        }
    }
#endif
