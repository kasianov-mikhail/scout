//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkEndpointHeader: View {
    let endpoint: NetworkEndpoint
    let descriptor: String

    var body: some View {
        VStack(alignment: .leading, spacing: .space6) {
            Text(verbatim: endpoint.path)
                .font(.scoutRowMono)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            methodText
                + Text(verbatim: " · " + phrase)
                .font(.scoutCaption)
                .foregroundColor(Color.textMuted)
        }
        .padding(.top, .space4)
        .padding(.bottom, .space16)
        .overlay(alignment: .bottom) {
            Separator()
        }
    }

    private var methodText: Text {
        guard let method = endpoint.method else {
            return Text(verbatim: "")
        }
        return Text(verbatim: method + " · ")
            .font(.scoutMonoLabel)
            .foregroundColor(endpoint.methodColor)
    }

    private var phrase: String {
        let count = "\(endpoint.requests.networkCount) \(endpoint.requests == 1 ? "request" : "requests")"
        var parts = ["\(count) \(descriptor)"]

        if let successRate = endpoint.successRate {
            parts.append("\(successRate.networkPercent) ok")
        }
        if let p99 = endpoint.p99 {
            parts.append("p99 \(p99.duration)")
        }

        return parts.joined(separator: " · ")
    }
}

struct NetworkEndpointHeaderPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .space6) {
            SkeletonBar(width: 210, height: 9, delay: 0.08)

            HStack(spacing: .space6) {
                SkeletonBar(width: 28, height: 9, delay: 0.08)
                SkeletonBar(width: 194, height: 9, delay: 0.08)
            }
        }
        .padding(.top, .space4)
        .padding(.bottom, .space16)
        .overlay(alignment: .bottom) {
            Separator()
        }
    }
}
