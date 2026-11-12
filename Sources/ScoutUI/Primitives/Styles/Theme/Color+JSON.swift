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

extension Color {
    static let jsonKey = adaptiveColor(light: 0x0550AE, dark: 0x79C0FF)
    static let jsonString = adaptiveColor(light: 0x0A3069, dark: 0xA5D6FF)
    static let jsonNumber = jsonKey
    static let jsonLiteral = jsonKey
    static let jsonPunctuation = adaptiveColor(light: 0x1F2328, dark: 0xE6EDF3)
    static let jsonBackground = adaptiveColor(light: 0xF6F8FA, dark: 0x161B22)
}

private func adaptiveColor(light: UInt32, dark: UInt32) -> Color {
    #if os(macOS)
        Color(
            nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(hex: dark)
                    : NSColor(hex: light)
            }
        )
    #else
        Color(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
            }
        )
    #endif
}

#if os(macOS)
    extension NSColor {
        fileprivate convenience init(hex: UInt32) {
            self.init(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        }
    }
#else
    extension UIColor {
        fileprivate convenience init(hex: UInt32) {
            self.init(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        }
    }
#endif
