//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ChartSnapshot<ChartContent: View>: View {
    let title: String
    let rangeLabel: String
    let showsTitle: Bool
    let showsRange: Bool
    var fadesHeader = false

    @ViewBuilder let chart: () -> ChartContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if fadesHeader {
                fadingHeader
            } else if showsTitle || showsRange {
                staticHeader
            }

            chart()
        }
    }

    private var fadingHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            titleText.opacity(showsTitle ? 1 : 0)
            rangeText.opacity(showsRange ? 1 : 0)
        }
        .padding([.top, .horizontal])
        .animation(.easeInOut(duration: 0.25), value: showsTitle)
        .animation(.easeInOut(duration: 0.25), value: showsRange)
    }

    private var staticHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            if showsTitle {
                titleText
            }
            if showsRange {
                rangeText
            }
        }
        .padding([.top, .horizontal])
    }

    private var titleText: some View {
        Text(verbatim: title).font(.fixedHeadline)
    }

    private var rangeText: some View {
        Text(verbatim: rangeLabel)
            .font(.fixedCaption)
            .foregroundStyle(.secondary)
    }
}
