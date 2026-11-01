//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeAlertSection: View {
    let history: AlertHistory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(verbatim: "ALERTS")
                        .font(.footnote.weight(.semibold))

                    Spacer()

                    if history.firing > 0 {
                        Text(verbatim: "\(history.firing) firing")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                }

                AlertHealthStrip(buckets: history.buckets)
                    .padding(.top, 4)

                HStack(alignment: .firstTextBaseline) {
                    Text(verbatim: history.summary)

                    Spacer()

                    Text(verbatim: history.rulesLabel)
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
            }
            .padding(.top, 12)
            .padding(.bottom, 14)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeAlertSection(history: .sample) {}
        }
    }
}
