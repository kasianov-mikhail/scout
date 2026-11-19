//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct AlertWeekCard: View {
    let week: AlertWeek?
    let draft: AlertDraft
    let isFailed: Bool

    var body: some View {
        let counts = week?.fireCounts(for: draft)
        let breaches = week?.breachGrid(for: draft.rule)

        AlertCard {
            VStack(spacing: 0) {
                summary(counts)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                countsRow(counts)
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                grid(breaches)
            }
        }
        .animation(.easeOut(duration: 0.2), value: week)
    }

    var dates: [Date] {
        if let dates = week?.days.map(\.date) {
            return dates
        }
        return AlertWeek.weekDays(ending: Date().startOfDay)
    }

    var isLoading: Bool {
        week == nil && !isFailed
    }

    private func summary(_ counts: [AlertDraft.Sensitivity: Int]?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if let count = counts?[draft.sensitivity] {
                Text(verbatim: "\(count)")
                    .font(.scoutNumberS)
                    .monospacedDigit()
            } else if isFailed {
                Text(verbatim: "—")
                    .font(.scoutNumberS)
            } else {
                SkeletonBar(width: 28, height: 16, delay: 0)
            }

            if isLoading {
                SkeletonBar(width: 120, height: 8, delay: 0)
                    .frame(height: 16, alignment: .leading)
                    .padding(.leading, .space4)
            } else {
                Text(verbatim: " alerts with \(draft.sensitivity.title)")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func countsRow(_ counts: [AlertDraft.Sensitivity: Int]?) -> some View {
        HStack(spacing: 0) {
            ForEach(AlertDraft.Sensitivity.allCases.indices, id: \.self) { index in
                let sensitivity = AlertDraft.Sensitivity.allCases[index]

                VStack(alignment: .leading, spacing: .space2) {
                    Text(verbatim: sensitivity.title)
                        .font(.scoutMicro)
                        .foregroundStyle(Color.textMuted)

                    if let count = counts?[sensitivity] {
                        Text(verbatim: "\(count)")
                            .font(.scoutRowStrong)
                            .monospacedDigit()
                    } else if isFailed {
                        Text(verbatim: "—")
                            .font(.scoutRowStrong)
                    } else {
                        SkeletonBar(width: 28, height: 11, delay: 0)
                    }
                }
                .padding(.vertical, .space8)
                .padding(.horizontal, .space8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    if index < AlertDraft.Sensitivity.allCases.count - 1 {
                        Separator(axis: .vertical)
                    }
                }
            }
        }
    }
}
