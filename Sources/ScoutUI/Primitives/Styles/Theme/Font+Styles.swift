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
    static let codeChip = Font.system(size: 13, design: .monospaced)
    static let listTitle = Font.system(size: 28, weight: .bold)
    static let telemetryTitle = scoutRow
    static let telemetryCaption = scoutCaption

    static func book(size: CGFloat, design: Font.Design = .default) -> Font {
        #if os(iOS)
            let weight = UIFont.Weight.regular
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
            let weight = NSFont.Weight.regular
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

/// The Scout design-system text styles.
///
/// Sizes are fixed: the app does not support Dynamic Type, so every style uses a
/// fixed system size and the root view caps the size at `.large`.
extension Font {
    static let scoutTitle = Font.system(size: 17, weight: .semibold)
    static let scoutBody = Font.system(size: 17)
    static let scoutSection = Font.system(size: 16, weight: .bold)
    static let scoutSectionAction = Font.system(size: 16, weight: .semibold)
    static let scoutTimelineRow = Font.system(size: 16, weight: .semibold)
    static let scoutEventName = Font.system(size: 16, design: .monospaced)
    static let scoutRow = Font.system(size: 15)
    static let scoutRowStrong = Font.system(size: 15, weight: .semibold)
    static let scoutRowMono = Font.system(size: 15, design: .monospaced)
    static let scoutRowMonoStrong = Font.system(size: 15, weight: .semibold, design: .monospaced)
    static let scoutCaption = Font.system(size: 13)
    static let scoutCaptionStrong = Font.system(size: 13, weight: .semibold)
    static let scoutValue = Font.system(size: 13, design: .monospaced)
    static let scoutValueStrong = Font.system(size: 13, weight: .semibold, design: .monospaced)
    static let scoutFootnote = Font.system(size: 12)
    static let scoutFootnoteStrong = Font.system(size: 12, weight: .semibold)
    static let scoutCode = Font.system(size: 12, design: .monospaced)
    static let scoutCodeStrong = Font.system(size: 12, weight: .semibold, design: .monospaced)
    static let scoutLabelCaps = Font.system(size: 11, weight: .semibold)
    static let scoutBadge = Font.system(size: 11, weight: .bold)
    static let scoutMicro = Font.system(size: 11)
    static let scoutMonoLabel = Font.system(size: 11, weight: .bold, design: .monospaced)
    static let scoutMonoCaption = Font.system(size: 11, design: .monospaced)
    static let scoutAxis = Font.system(size: 10, design: .monospaced)
    static let scoutHeadline = Font.system(size: 28, weight: .bold)
    static let scoutNavEvent = Font.system(size: 17, weight: .semibold, design: .monospaced)
    static let scoutNumberXL = Font.system(size: 34, weight: .bold, design: .rounded)
    static let scoutNumberL = Font.system(size: 28, weight: .bold, design: .rounded)
    static let scoutNumberM = Font.system(size: 24, weight: .bold, design: .rounded)
    static let scoutNumberS = Font.system(size: 20, weight: .bold, design: .rounded)
}
