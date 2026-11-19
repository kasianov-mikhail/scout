//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

enum StartPeriod: CaseIterable, Identifiable {
    case today
    case week
    case month
    case year

    var id: Self { self }

    var title: String {
        switch self {
        case .today:
            "Today"
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .year:
            "Year"
        }
    }
}

extension SettingsOverviewView {
    func segment(title: String, isSelected: Bool, showsDivider: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsSegmentCell(title: title, isSelected: isSelected, showsDivider: showsDivider)
        }
        .buttonStyle(.plain)
    }
}
