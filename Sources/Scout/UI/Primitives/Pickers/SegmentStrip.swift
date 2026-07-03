//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SegmentStrip<Value: Hashable>: View {
    @Binding var selection: Value

    let values: [Value]
    let tint: ((Value) -> Color)?
    let title: (Value) -> String

    @Namespace private var namespace

    var body: some View {
        ForEach(values, id: \.self) { value in
            segment(value)
        }
    }

    @ViewBuilder
    private func segment(_ value: Value) -> some View {
        let isSelected = value == selection
        let tint = tint?(value) ?? .primary

        Text(title(value).uppercased())
            .font(.system(size: 14, weight: isSelected ? .bold : .medium))
            .foregroundStyle(isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(.secondary))
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Capsule()
                        .fill(tint)
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "indicator", in: namespace)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selection)
            .contentShape(.rect)
            .onTapGesture { selection = value }
    }
}

extension SegmentStrip where Value: CaseIterable {
    init(selection: Binding<Value>, tint: @escaping (Value) -> Color = { _ in .primary }, title: @escaping (Value) -> String) {
        self.init(
            selection: selection,
            values: Array(Value.allCases),
            tint: tint,
            title: title
        )
    }
}

#Preview {
    struct Preview: View {
        @State private var selection = Period.today

        var body: some View {
            VStack(spacing: 24) {
                JustifiedLayout {
                    SegmentStrip(selection: $selection) { $0.shortTitle }
                }
                HStack(spacing: 20) {
                    SegmentStrip(selection: $selection) { $0.shortTitle }
                }
            }
            .padding()
        }
    }
    return Preview()
}
