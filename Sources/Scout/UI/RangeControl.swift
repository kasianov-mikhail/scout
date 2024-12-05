//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RangeControl: View {
    let period: StatPeriod
    @Binding var range: Range<Date>

    var body: some View {
        HStack {
            let leftRange = range.moved(by: period.rangeComponent, value: -1)
            let yearRange = StatPeriod.year.range

            MoveButton(image: "chevron.left") {
                range.move(by: period.rangeComponent, value: -1)
            }
            .disabled(leftRange.lowerBound < yearRange.lowerBound)

            Text(range.rangeText)
                .font(.system(size: 16))
                .monospaced()
                .frame(height: 44)
                .frame(maxWidth: .infinity)

            MoveButton(image: "chevron.right") {
                range.move(by: period.rangeComponent, value: 1)
            }
            .simultaneousGesture(
                LongPressGesture().onEnded { _ in
                    range = period.range
                }
            )
            .disabled(range == period.range)
        }
    }

    struct MoveButton: View {
        let image: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: image)
            }
            .font(.system(size: 16))
            .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Range Extensions

extension Range<Date> {

    var rangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let from = formatter.string(from: lowerBound)
        let to = formatter.string(from: upperBound.addingDay(-1))

        if from == to {
            return from
        } else {
            return "\(from) - \(to)"
        }
    }

    mutating func move(by component: Calendar.Component, value: Int) {
        self = moved(by: component, value: value)
    }

    func moved(by component: Calendar.Component, value: Int) -> Self {
        let lowerBound = lowerBound.adding(component, value: value)
        let upperBound = upperBound.adding(component, value: value)
        return lowerBound..<upperBound
    }
}
