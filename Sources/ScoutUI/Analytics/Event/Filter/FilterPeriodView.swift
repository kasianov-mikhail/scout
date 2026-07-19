//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterPeriodView: View {
    @ObservedObject var draft: FilterDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Header(title: "Period")

            Toggle(isOn: $draft.isDateRangeEnabled.animation()) {
                Text(verbatim: "Date range").font(.callout)
            }
            .padding(14)
            .softCell()

            if draft.isDateRangeEnabled {
                HStack(spacing: 10) {
                    dateBox("From", selection: $draft.startDate)
                    dateBox("To", selection: $draft.endDate)
                }
            }
        }
    }

    private func dateBox(_ title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title).font(.caption).foregroundStyle(.secondary)
            DatePicker(selection: selection, displayedComponents: .date) {
                Text(verbatim: title)
            }
            .labelsHidden()
            .environment(\.calendar, Calendar.utc)
            .environment(\.timeZone, Calendar.utc.timeZone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .softCell()
    }
}
