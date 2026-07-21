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
        VStack(alignment: .leading, spacing: 16) {
            Header(title: "Period")

            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $draft.isDateRangeEnabled.animation()) {
                    Text(verbatim: "Date range").font(.callout)
                }
                .softCell()

                if draft.isDateRangeEnabled {
                    HStack(spacing: 10) {
                        dateBox("From", selection: $draft.startDate)
                        dateBox("To", selection: $draft.endDate)
                    }
                }
            }
        }
    }

    private func dateBox(_ title: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title).font(.caption).foregroundStyle(.secondary)

            Text(verbatim: dateBoxFormatter.string(from: selection.wrappedValue))
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay {
                    DatePicker(selection: selection, displayedComponents: .date) {
                        Text(verbatim: title)
                    }
                    .labelsHidden()
                    .blendMode(.destinationOver)
                    .environment(\.calendar, Calendar.utc)
                    .environment(\.timeZone, Calendar.utc.timeZone)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCell()
    }
}

private let dateBoxFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.calendar = .utc
    formatter.timeZone = Calendar.utc.timeZone
    formatter.dateFormat = "d MMM yyyy"
    return formatter
}()
