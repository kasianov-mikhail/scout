//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

extension AlertWeekCard {
    func grid(_ breaches: [[Bool]]?) -> some View {
        VStack(spacing: .space2) {
            ForEach(dates.indices, id: \.self) { day in
                HStack(spacing: .space2) {
                    if isLoading {
                        SkeletonBar(width: 24, height: 7, delay: 0)
                            .frame(width: 34, alignment: .leading)
                    } else {
                        Text(verbatim: alertWeekdayFormatter.string(from: dates[day]))
                            .font(.scoutAxis)
                            .foregroundStyle(Color.textMuted)
                            .frame(width: 34, alignment: .leading)
                    }

                    HStack(spacing: .space2) {
                        ForEach(0..<24, id: \.self) { hour in
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(cellColor(breaches, day: day, hour: hour))
                                .frame(height: 12)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 15)
            }

            HStack(spacing: 0) {
                Color.clear.frame(width: 34, height: 1)

                HStack(spacing: 0) {
                    if isLoading {
                        ForEach(0..<5, id: \.self) { index in
                            if index > 0 {
                                Spacer()
                            }

                            SkeletonBar(width: 18, height: 7, delay: 0)
                        }
                    } else {
                        Text(verbatim: "00")
                        Spacer()
                        Text(verbatim: "06")
                        Spacer()
                        Text(verbatim: "12")
                        Spacer()
                        Text(verbatim: "18")
                        Spacer()
                        Text(verbatim: "24")
                    }
                }
                .font(.scoutAxis)
                .foregroundStyle(Color.textMuted)
                .frame(height: 12)
            }
            .padding(.top, .space4)
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
    }

    private func cellColor(_ breaches: [[Bool]]?, day: Int, hour: Int) -> Color {
        guard let breaches else {
            return Color.surfaceGrey
        }
        guard breaches.indices.contains(day) else {
            return Color.surfaceGrey
        }
        guard breaches[day].indices.contains(hour) else {
            return Color.surfaceGrey
        }
        return breaches[day][hour] ? Color.fillDanger : Color.surfaceSkeleton
    }
}

private let alertWeekdayFormatter = DateFormatter(format: "EEE")
