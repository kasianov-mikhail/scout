//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ChartExportOptions: Equatable {
    var format: ChartExportFormat = .png
    var appearance: ChartExportAppearance = .system
    var includesTitle = true
    var includesRange = true
}

enum ChartExportFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case pdf = "PDF"

    var id: Self { self }

    var fileExtension: String {
        rawValue.lowercased()
    }
}

enum ChartExportAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: Self { self }

    func resolvedScheme(current: ColorScheme) -> ColorScheme {
        switch self {
        case .system:
            current
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
