//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseTile: View {
    let value: ReleaseTileValue
    let isLeading: Bool
    let action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cell
                }
                .buttonStyle(.plain)
            } else {
                cell
            }
        }
    }

    private var cell: some View {
        content
            .releaseGridCell(isLeading: isLeading)
            .contentShape(Rectangle())
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: .space6) {
            Text(verbatim: value.kind.title)
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)

            Text(verbatim: value.value)
                .font(.scoutNumberM)
                .monospacedDigit()
                .foregroundStyle(value.color)

            ReleaseChartView(chart: value.chart)
                .frame(height: 24)

            if let footer = value.footer {
                Text(verbatim: footer)
                    .font(.scoutFootnote)
                    .foregroundStyle(Color.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
    }
}

extension View {
    func releaseGridCell(isLeading: Bool) -> some View {
        padding(.vertical, 14)
            .padding(.leading, isLeading ? 0 : 12)
            .padding(.trailing, isLeading ? 12 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .overlay(alignment: .trailing) {
                if isLeading {
                    Separator(axis: .vertical)
                }
            }
            .overlay(alignment: .bottom) {
                Separator()
            }
    }
}

#Preview {
    let release = [ReleaseHealth].samples[0]
    let detail = ReleaseDetail(release: release, trend: .sample, now: Date())

    VStack(spacing: 0) {
        HStack(spacing: 0) {
            ReleaseTile(value: detail.tiles[0], isLeading: true, action: nil)
            ReleaseTile(value: detail.tiles[1], isLeading: false, action: nil)
        }
        HStack(spacing: 0) {
            ReleaseTile(value: detail.tiles[2], isLeading: true, action: {})
            ReleaseTile(value: detail.tiles[3], isLeading: false, action: {})
        }
    }
    .padding(.horizontal, .gutter)
}
