//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

extension Font {
    static let placeholderTitle = scoutTitle
    static let codeChip = Font.book(size: 13, design: .monospaced)
    static let listTitle = Font.system(size: 28, weight: .bold)
    static let telemetryTitle = scoutRow
    static let telemetryCaption = scoutCaption

    static func book(size: CGFloat, design: Font.Design = .default) -> Font {
        platformFont(size: size, axisWeight: 0.12, design: design)
    }

    /// A system font at a numerical weight on the variable axis, such as 450 or 650.
    ///
    /// The numerical weights map to the system font's axis through the raw values that
    /// `UIFont.Weight` and `NSFont.Weight` use: 400 is 0, 600 is 0.3, 700 is 0.4. The
    /// values between them are interpolated, and 450 keeps the app's existing 0.12.
    static func variable(size: CGFloat, weight: CGFloat, design: Font.Design = .default) -> Font {
        platformFont(size: size, axisWeight: axisWeight(weight), design: design)
    }

    private static func platformFont(size: CGFloat, axisWeight: CGFloat, design: Font.Design) -> Font {
        #if os(iOS)
            let weight = UIFont.Weight(rawValue: axisWeight)
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
            let weight = NSFont.Weight(rawValue: axisWeight)
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

    private static func axisWeight(_ weight: CGFloat) -> CGFloat {
        switch weight {
        case 100: return -0.8
        case 200: return -0.6
        case 300: return -0.4
        case 400: return 0
        case 450: return 0.12
        case 500: return 0.23
        case 600: return 0.3
        case 650: return 0.35
        case 700: return 0.4
        case 750: return 0.48
        case 800: return 0.56
        case 900: return 0.62
        default:
            let clamped = min(max(weight, 100), 900)
            let lower = (clamped / 100).rounded(.down) * 100
            let upper = min(lower + 100, 900)
            let progress = (clamped - lower) / 100
            return axisWeight(lower) + (axisWeight(upper) - axisWeight(lower)) * progress
        }
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

/// The Scout design-system text styles.
///
/// Sizes are fixed: the app does not support Dynamic Type, so every style uses a
/// fixed system size and the root view caps the size at `.large`.
extension Font {
    static let scoutTitle = Font.system(size: 17, weight: .semibold)
    static let scoutBody = Font.book(size: 17)
    static let scoutSection = Font.system(size: 16, weight: .bold)
    static let scoutSectionAction = Font.system(size: 16, weight: .semibold)
    static let scoutTimelineRow = Font.system(size: 16, weight: .semibold)
    static let scoutEventName = Font.book(size: 16, design: .monospaced)
    static let scoutRow = Font.book(size: 15)
    static let scoutRowStrong = Font.system(size: 15, weight: .semibold)
    static let scoutRowMono = Font.book(size: 15, design: .monospaced)
    static let scoutRowMonoStrong = Font.system(size: 15, weight: .semibold, design: .monospaced)
    static let scoutCaption = Font.book(size: 13)
    static let scoutCaptionStrong = Font.system(size: 13, weight: .semibold)
    static let scoutValue = Font.book(size: 13, design: .monospaced)
    static let scoutValueStrong = Font.system(size: 13, weight: .semibold, design: .monospaced)
    static let scoutFootnote = Font.book(size: 12)
    static let scoutFootnoteStrong = Font.system(size: 12, weight: .semibold)
    static let scoutCode = Font.book(size: 12, design: .monospaced)
    static let scoutCodeStrong = Font.system(size: 12, weight: .semibold, design: .monospaced)
    static let scoutLabelCaps = Font.system(size: 11, weight: .semibold)
    static let scoutBadge = Font.system(size: 11, weight: .bold)
    static let scoutMicro = Font.book(size: 11)
    static let scoutMonoLabel = Font.system(size: 11, weight: .bold, design: .monospaced)
    static let scoutMonoCaption = Font.book(size: 11, design: .monospaced)
    static let scoutAxis = Font.book(size: 10, design: .monospaced)
    static let scoutHeadline = Font.system(size: 28, weight: .bold)
    static let scoutNavEvent = Font.system(size: 17, weight: .semibold, design: .monospaced)
    static let scoutNumberXL = Font.system(size: 34, weight: .bold, design: .rounded)
    static let scoutNumberL = Font.system(size: 28, weight: .bold, design: .rounded)
    static let scoutNumberM = Font.system(size: 24, weight: .bold, design: .rounded)
    static let scoutNumberS = Font.system(size: 20, weight: .bold, design: .rounded)
}
