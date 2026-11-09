//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeTelemetrySectionPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(verbatim: "TELEMETRY")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(verbatim: "INCIDENTS")
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.callout.weight(.bold))
            .padding(.top, 12)
            .frame(height: 70)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }

            LazyVGrid(columns: telemetryColumns, spacing: 0) {
                ForEach(Array([TelemetryItem.Kind.events, .crashes, .metrics, .hangs, .network, .resources].enumerated()), id: \.element) { index, kind in
                    row(kind: kind, index: index)
                }
            }
            .overlay {
                Rectangle()
                    .fill(Color.separator)
                    .frame(width: 0.5)
                    .allowsHitTesting(false)
            }
        }
        .padding(.bottom, 6)
    }

    private func row(kind: TelemetryItem.Kind, index: Int) -> some View {
        let delay = 0.72 + Double(index / 2) * 0.08

        return HStack(alignment: .top, spacing: 8) {
            Image(systemName: kind.systemImage)
                .font(.weight450(size: 18))
                .foregroundStyle(kind.color)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(verbatim: kind.title)
                        .font(.weight450(size: 16))

                    Spacer(minLength: 0)

                    SkeletonBar(width: 28, height: 11, delay: delay)
                }
                .frame(height: 20)

                SkeletonBar(width: 74, height: 8, delay: delay)
                    .frame(height: 15, alignment: .leading)
            }
        }
        .padding(.leading, index.isMultiple(of: 2) ? 0 : 12)
        .padding(.trailing, index.isMultiple(of: 2) ? 12 : 0)
        .frame(height: 66)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if index / 2 < 2 {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
        }
    }
}
