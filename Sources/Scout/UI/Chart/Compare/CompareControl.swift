//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct CompareControl<T: ChartTimeScale>: View {
    @Binding var extent: ChartExtent<T>

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        HStack {
            Button {
                extent.isComparing.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right")
                    Text(verbatim: "Compare")
                }
                .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
            .tint(extent.isComparing ? .blue : .secondary)

            Spacer()

            if extent.isComparing {
                Text(verbatim: "vs \(extent.previousDomain.label(using: formatter))")
                    .font(.system(size: 14))
                    .monospaced()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 16) {
        CompareControl(
            extent: .constant(ChartExtent(period: Period.week))
        )

        CompareControl(
            extent: .constant(
                ChartExtent(
                    period: Period.week,
                    domain: Period.week.initialRange,
                    isComparing: true
                )
            )
        )
    }
}
