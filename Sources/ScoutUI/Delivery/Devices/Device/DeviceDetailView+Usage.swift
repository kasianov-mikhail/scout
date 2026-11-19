//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct UsageGrid: View {
    let usage: DeviceUsage

    private let labels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: .space2) {
            ForEach(0..<7, id: \.self) { day in
                HStack(spacing: .space6) {
                    Text(verbatim: labels[day])
                        .font(.book(size: 10))
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 10, alignment: .leading)

                    HStack(spacing: .space2) {
                        ForEach(0..<24, id: \.self) { hour in
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(color(day: day, hour: hour))
                                .frame(height: 12)
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                Text(verbatim: "00")
                Spacer()
                Text(verbatim: "06")
                Spacer()
                Text(verbatim: "12")
                Spacer()
                Text(verbatim: "18")
                Spacer()
                Text(verbatim: "23")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .padding(.leading, .gutter)
            .padding(.top, .space2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Sessions by weekday and hour"))
    }

    private func color(day: Int, hour: Int) -> Color {
        let count = usage.counts[day][hour]
        guard count > 0, usage.maxCount > 0 else {
            return .deviceShade
        }

        let share = Double(count) / Double(usage.maxCount)
        if share > 0.66 {
            return .deviceAccent
        }
        if share > 0.33 {
            return .deviceAccentSoft
        }
        return .deviceTrack
    }
}

extension Color {
    static let deviceAccent = fillDevice
    static let deviceAccentSoft = Color(red: 0x9E / 255, green: 0xD8 / 255, blue: 0xF3 / 255)
    static let deviceTrack = surfaceTrack
    static let deviceShade = surfaceGrey
}
