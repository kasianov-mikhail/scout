//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct BackendRetentionSection: View {
    @AppStorage private var retention: BackendRetention

    init(id: String) {
        _retention = AppStorage(wrappedValue: .year, BackendRetention.key(id: id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsLabel(title: "KEEP DATA FOR")

            SettingsStrip {
                ForEach(BackendRetention.allCases) { option in
                    Button {
                        retention = option
                    } label: {
                        SettingsSegmentCell(
                            title: option.title,
                            isSelected: retention == option,
                            showsDivider: option != BackendRetention.allCases.last
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .hapticFeedback(.selection, trigger: retention)

            SettingsNote(text: "Saved on this device. Server-side deletion is not available yet.")
        }
    }
}
