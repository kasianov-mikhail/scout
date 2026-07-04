//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SegmentStrip<Value: Hashable>: View {
    enum Distribution {
        case compact(spacing: CGFloat)
        case justified
    }

    @Binding var selection: Value

    let values: [Value]
    let distribution: Distribution
    let tint: ((Value) -> Color)?
    let title: (Value) -> String

    @Namespace private var namespace

    init(
        selection: Binding<Value>,
        values: [Value],
        distribution: Distribution = .compact(spacing: 20),
        tint: ((Value) -> Color)? = { _ in .primary },
        title: @escaping (Value) -> String
    ) {
        self._selection = selection
        self.values = values
        self.distribution = distribution
        self.tint = tint
        self.title = title
    }

    var body: some View {
        strip
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottom) {
                Divider()
            }
    }

    @ViewBuilder
    private var strip: some View {
        switch distribution {
        case .compact(let spacing):
            HStack(spacing: spacing) {
                segments
            }
        case .justified:
            JustifiedLayout {
                segments
            }
        }
    }

    @ViewBuilder
    private var segments: some View {
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
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selection = value
                }
            }
    }
}

extension SegmentStrip where Value: CaseIterable {
    init(
        selection: Binding<Value>,
        distribution: Distribution = .compact(spacing: 20),
        tint: @escaping (Value) -> Color = { _ in .primary },
        title: @escaping (Value) -> String
    ) {
        self.init(
            selection: selection,
            values: Array(Value.allCases),
            distribution: distribution,
            tint: tint,
            title: title
        )
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var selection = Period.today

    VStack(spacing: 24) {
        SegmentStrip(selection: $selection, distribution: .justified) { $0.shortTitle }
        SegmentStrip(selection: $selection) { $0.shortTitle }
    }
    .padding()
}
