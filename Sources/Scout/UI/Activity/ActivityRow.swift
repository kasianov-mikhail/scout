//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityRow: View {
    let period: ActivityPeriod
    var systemImage: String? = nil

    @ObservedObject var activity: ActivityProvider

    var body: some View {
        Row {
            if let systemImage {
                Image(systemName: systemImage)
                    .frame(width: 24)
            }
            Text(period.title)
                .foregroundColor(.primary)
            Spacer()

            let count = try? activity.result?.get()
                .points(on: period)
                .bucket(on: period)
                .max()?
                .count

            RedactedText(count: count)
        } destination: {
            ActivityView(activity: activity, period: period)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            ActivityRow(
                period: .daily,
                activity: ActivityProvider()
            )
        }
    }
}
