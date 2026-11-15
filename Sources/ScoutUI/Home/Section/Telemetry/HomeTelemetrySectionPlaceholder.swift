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
                    .padding(.leading, .space12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.scoutSection)
            .padding(.top, .space12)
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
        .padding(.bottom, .space6)
    }

    private func row(kind: TelemetryItem.Kind, index: Int) -> some View {
        let delay = 0.72 + Double(index / 2) * 0.08

        return HStack(alignment: .top, spacing: .space8) {
            SkeletonBar(width: 18, height: 18, delay: delay, cornerRadius: .radiusBadge)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: .space2) {
                HStack(spacing: .space8) {
                    SkeletonBar(width: kind.skeletonWidth, height: 9, delay: delay)

                    Spacer(minLength: 0)

                    SkeletonBar(width: 28, height: 11, delay: delay)
                }
                .frame(height: 20)

                SkeletonBar(width: 74, height: 8, delay: delay)
                    .frame(height: 15)
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

extension TelemetryItem.Kind {
    fileprivate var skeletonWidth: CGFloat {
        switch self {
        case .events: 46
        case .crashes: 56
        case .metrics: 50
        case .hangs: 44
        case .network: 58
        case .resources: 74
        }
    }
}
