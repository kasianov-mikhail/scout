//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkEndpointRow: View {
    let endpoint: NetworkEndpoint
    let maxRequests: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                if let method = endpoint.method {
                    Text(verbatim: method)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(endpoint.methodColor)
                }

                Text(verbatim: endpoint.path)
                    .font(.book(size: 13, design: .monospaced))
                    .lineLimit(1)
                    .mask(alignment: .trailing) {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(.black)
                            LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                                .frame(width: 28)
                        }
                    }
            }

            HStack(spacing: 8) {
                BarValue(text: endpoint.requests.compact, fraction: fraction, color: .networkTrack, barHeight: 25.5, minimumWidth: 4)
                    .frame(maxWidth: .infinity)
                    .frame(height: 18)

                Text(verbatim: endpoint.successRate.networkValue)
                    .foregroundStyle(endpoint.successRate.networkColor)
                    .frame(width: 56, alignment: .trailing)

                Text(verbatim: endpoint.p99.networkP99Value)
                    .font(.weighted(size: 13, weight: endpoint.p99.networkP99Weight, design: .monospaced))
                    .foregroundStyle(endpoint.p99.networkP99Color)
                    .frame(width: 64, alignment: .trailing)
            }
            .font(.book(size: 13, design: .monospaced))
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: .rowChart)
        .overlay(alignment: .bottom) {
            DashedLine()
        }
        .contentShape(.rect)
    }

    private var fraction: Double {
        maxRequests > 0 ? Double(endpoint.requests) / Double(maxRequests) : 0
    }
}
