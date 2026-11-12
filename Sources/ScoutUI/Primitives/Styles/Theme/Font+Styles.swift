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
    static let codeChip = Font.book(size: 14, design: .monospaced)
    static let listTitle = Font.system(size: 28, weight: .bold)
    static let telemetryTitle = Font.book(size: 16)
    static let telemetryCaption = Font.book(size: 13)

    static func book(size: CGFloat, design: Font.Design = .default) -> Font {
        #if os(iOS)
            let weight = UIFont.Weight(rawValue: 0.12)
            switch design {
            case .monospaced:
                return Font(UIFont.monospacedSystemFont(ofSize: size, weight: weight))
            case .rounded, .serif:
                let base = UIFont.systemFont(ofSize: size, weight: weight)
                let systemDesign: UIFontDescriptor.SystemDesign = design == .rounded ? .rounded : .serif
                let descriptor = base.fontDescriptor.withDesign(systemDesign) ?? base.fontDescriptor
                return Font(UIFont(descriptor: descriptor, size: size))
            default:
                return Font(UIFont.systemFont(ofSize: size, weight: weight))
            }
        #else
            let weight = NSFont.Weight(rawValue: 0.12)
            switch design {
            case .monospaced:
                return Font(NSFont.monospacedSystemFont(ofSize: size, weight: weight))
            case .rounded, .serif:
                let base = NSFont.systemFont(ofSize: size, weight: weight)
                let systemDesign: NSFontDescriptor.SystemDesign = design == .rounded ? .rounded : .serif
                let descriptor = base.fontDescriptor.withDesign(systemDesign) ?? base.fontDescriptor
                return Font(NSFont(descriptor: descriptor, size: size) ?? base)
            default:
                return Font(NSFont.systemFont(ofSize: size, weight: weight))
            }
        #endif
    }

    static func weighted(size: CGFloat, weight: Font.Weight, design: Font.Design) -> Font {
        switch weight {
        case .regular, .medium:
            .book(size: size, design: design)
        default:
            .system(size: size, weight: weight, design: design)
        }
    }
}
