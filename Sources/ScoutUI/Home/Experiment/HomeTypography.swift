//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SwiftUI

/// The Home text roles from the design.
///
/// Every visible string on Home belongs to one.
enum HomeTextRole: Equatable, Sendable {
    case nav
    case section
    case label
    case labelInk
    case status
    case number
    case numberDim
    case headline
    case tileValue
    case row
    case suffix
    case caption
    case delta
    case legend
    case axis
    case monoValue
    case monoDim
    case monoOff
    case stripLabel

    var size: CGFloat {
        switch self {
        case .nav:
            17
        case .section:
            16
        case .label, .labelInk, .status, .caption, .delta, .monoValue, .monoDim, .monoOff:
            13
        case .number, .numberDim:
            28
        case .headline:
            24
        case .tileValue:
            17
        case .row, .suffix:
            15
        case .legend:
            12
        case .axis, .stripLabel:
            10
        }
    }

    var weight: HomeTextWeight {
        switch self {
        case .row, .suffix, .caption, .delta, .legend, .axis, .monoDim, .monoOff:
            .regular
        case .nav, .label, .labelInk, .status, .tileValue, .monoValue, .stripLabel:
            .strong
        case .section, .number, .numberDim, .headline:
            .bold
        }
    }

    var design: Font.Design {
        switch self {
        case .number, .numberDim, .headline:
            .rounded
        case .axis, .monoValue, .monoDim, .monoOff, .stripLabel:
            .monospaced
        default:
            .default
        }
    }

    var color: HomeTextColor {
        switch self {
        case .label, .suffix, .caption, .legend, .axis, .monoDim:
            .muted
        case .numberDim:
            .secondary
        case .monoValue:
            .positive
        case .monoOff:
            .disabled
        case .stripLabel:
            .onFill
        case .status, .delta:
            .inherit
        case .nav, .section, .labelInk, .number, .headline, .tileValue, .row:
            .primary
        }
    }

    /// Roles at 10–13 pt that follow the variant's small-size bump and tracking.
    ///
    /// The mono-off role is excluded: the design keeps “in 2 d” unchanged in every variant.
    var isSmall: Bool {
        switch self {
        case .label, .labelInk, .status, .caption, .delta, .legend, .axis, .monoValue, .monoDim, .stripLabel:
            true
        default:
            false
        }
    }
}

enum HomeTextWeight: Equatable, Sendable {
    case regular
    case strong
    case bold
}

enum HomeTextColor: Equatable, Sendable {
    case inherit
    case primary
    case muted
    case secondary
    case positive
    case disabled
    case onFill
}

/// The typography parameters that vary across the 20 Home experiment variants.
struct HomeTypography: Equatable, Sendable {
    let id: String
    let regular: CGFloat
    let strong: CGFloat
    let bold: CGFloat
    let muted: UInt32
    let secondary: UInt32
    var smallIncrement: CGFloat = 0
    var smallTracking: CGFloat = 0

    var label: String {
        var parts = ["\(id) · \(Int(regular)) · \(Self.hex(muted))"]

        if smallIncrement != 0 {
            parts.append("+\(Int(smallIncrement))")
        }
        if strong != Self.v01.strong || bold != Self.v01.bold {
            parts.append("\(Int(strong))/\(Int(bold))")
        }
        if secondary != Self.v01.secondary {
            parts.append("sec \(Self.hex(secondary))")
        }
        if smallTracking != 0 {
            parts.append("tr +\(String(format: "%g", smallTracking))")
        }

        return parts.joined(separator: " · ")
    }

    func size(_ role: HomeTextRole) -> CGFloat {
        role.size + (role.isSmall ? smallIncrement : 0)
    }

    func weightValue(_ role: HomeTextRole) -> CGFloat {
        switch role.weight {
        case .regular:
            regular
        case .strong:
            strong
        case .bold:
            bold
        }
    }

    func font(_ role: HomeTextRole) -> Font {
        .variable(size: size(role), weight: weightValue(role), design: role.design)
    }

    func tracking(_ role: HomeTextRole) -> CGFloat {
        role.isSmall ? smallTracking : 0
    }

    func color(_ role: HomeTextRole) -> Color? {
        switch role.color {
        case .inherit:
            nil
        case .primary:
            .textPrimary
        case .muted:
            designColor(light: muted, dark: muted)
        case .secondary:
            designColor(light: secondary, dark: secondary)
        case .positive:
            .positive
        case .disabled:
            .textDisabled
        case .onFill:
            .textOnFill
        }
    }

    private static func hex(_ value: UInt32) -> String {
        let digits = String(value, radix: 16, uppercase: true)
        return "#" + String(repeating: "0", count: 6 - digits.count) + digits
    }
}

extension HomeTypography {
    static let v01 = HomeTypography(id: "V01", regular: 400, strong: 600, bold: 700, muted: 0x8E8E93, secondary: 0x6C6C70)
    static let v02 = HomeTypography(id: "V02", regular: 450, strong: 600, bold: 700, muted: 0x8E8E93, secondary: 0x6C6C70)
    static let v03 = HomeTypography(id: "V03", regular: 400, strong: 600, bold: 700, muted: 0x7C7C80, secondary: 0x6C6C70)
    static let v04 = HomeTypography(id: "V04", regular: 400, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x6C6C70)
    static let v05 = HomeTypography(id: "V05", regular: 400, strong: 600, bold: 700, muted: 0x636366, secondary: 0x636366)
    static let v06 = HomeTypography(id: "V06", regular: 450, strong: 600, bold: 700, muted: 0x7C7C80, secondary: 0x6C6C70)
    static let v07 = HomeTypography(id: "V07", regular: 450, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x6C6C70)
    static let v08 = HomeTypography(id: "V08", regular: 450, strong: 600, bold: 700, muted: 0x636366, secondary: 0x636366)
    static let v09 = HomeTypography(id: "V09", regular: 500, strong: 600, bold: 700, muted: 0x8E8E93, secondary: 0x6C6C70)
    static let v10 = HomeTypography(id: "V10", regular: 500, strong: 600, bold: 700, muted: 0x7C7C80, secondary: 0x6C6C70)
    static let v11 = HomeTypography(id: "V11", regular: 500, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x6C6C70)
    static let v12 = HomeTypography(id: "V12", regular: 400, strong: 600, bold: 700, muted: 0x8E8E93, secondary: 0x6C6C70, smallIncrement: 1)
    static let v13 = HomeTypography(id: "V13", regular: 450, strong: 600, bold: 700, muted: 0x7C7C80, secondary: 0x6C6C70, smallIncrement: 1)
    static let v14 = HomeTypography(id: "V14", regular: 450, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x6C6C70, smallIncrement: 1)
    static let v15 = HomeTypography(id: "V15", regular: 450, strong: 650, bold: 750, muted: 0x6C6C70, secondary: 0x6C6C70)
    static let v16 = HomeTypography(id: "V16", regular: 500, strong: 650, bold: 750, muted: 0x6C6C70, secondary: 0x6C6C70)
    static let v17 = HomeTypography(id: "V17", regular: 450, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x48484A)
    static let v18 = HomeTypography(id: "V18", regular: 450, strong: 600, bold: 700, muted: 0x636366, secondary: 0x48484A, smallIncrement: 1)
    static let v19 = HomeTypography(id: "V19", regular: 400, strong: 600, bold: 700, muted: 0x8E8E93, secondary: 0x6C6C70, smallTracking: 0.2)
    static let v20 = HomeTypography(id: "V20", regular: 450, strong: 600, bold: 700, muted: 0x6C6C70, secondary: 0x6C6C70, smallTracking: 0.2)

    static let variants = [
        v01, v02, v03, v04, v05, v06, v07, v08, v09, v10,
        v11, v12, v13, v14, v15, v16, v17, v18, v19, v20,
    ]

    static func variant(id: String) -> HomeTypography {
        variants.first { $0.id == id } ?? v01
    }
}

extension EnvironmentValues {
    @Entry var homeTypography = HomeTypography.v01
}

private struct HomeTextStyle: ViewModifier {
    @Environment(\.homeTypography) private var typography

    let role: HomeTextRole

    @ViewBuilder
    func body(content: Content) -> some View {
        if let color = typography.color(role) {
            content
                .font(typography.font(role))
                .foregroundStyle(color)
                .tracking(typography.tracking(role))
        } else {
            content
                .font(typography.font(role))
                .tracking(typography.tracking(role))
        }
    }
}

extension View {
    /// Applies the font, color and tracking of a Home text role.
    func homeText(_ role: HomeTextRole) -> some View {
        modifier(HomeTextStyle(role: role))
    }
}

#Preview("Roles") {
    ScrollView {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: "Home").homeText(.nav)
            Text(verbatim: "ACTIVE USERS").homeText(.section)
            Text(verbatim: "DAU").homeText(.label)
            Text(verbatim: "ALERTS").homeText(.labelInk)
            Text(verbatim: "1 firing").homeText(.status).foregroundStyle(Color.textDanger)
            Text(verbatim: "1,212").homeText(.number)
            Text(verbatim: "8,412").homeText(.numberDim)
            Text(verbatim: "62% on 3.2.0").homeText(.headline)
            Text(verbatim: "48").homeText(.tileValue)
            Text(verbatim: "Events").homeText(.row)
            Text(verbatim: "of sessions").homeText(.suffix)
            Text(verbatim: "Crash-free sessions · 4 armed · 1 muted").homeText(.caption)
            Text(verbatim: "+4.1%").homeText(.delta).foregroundStyle(Color.positive)
            Text(verbatim: "healthy · watch · at risk · critical").homeText(.legend)
            Text(verbatim: "Sep 26 · Oct 10 · today").homeText(.axis)
            Text(verbatim: "192").homeText(.monoValue)
            Text(verbatim: " · 20%").homeText(.monoDim)
            Text(verbatim: "in 2 d").homeText(.monoOff)
        }
        .padding()
    }
}
