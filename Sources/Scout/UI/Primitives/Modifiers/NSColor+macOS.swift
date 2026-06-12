//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if os(macOS)
    import AppKit

    /// Stand-in for the iOS-only tiered system gray, matching its light and dark values.
    extension NSColor {
        static var systemGray3: NSColor {
            NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(red: 72 / 255, green: 72 / 255, blue: 74 / 255, alpha: 1)
                    : NSColor(red: 199 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1)
            }
        }
    }
#endif
