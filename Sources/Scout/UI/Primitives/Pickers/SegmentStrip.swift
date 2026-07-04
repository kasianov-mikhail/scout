//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SegmentStrip<Value: Hashable & CaseIterable>: View {
    enum Distribution {
        case compact(spacing: CGFloat)
        case justified
    }

    @Binding var selection: Value

    var values: [Value] = Array(Value.allCases)
    var distribution: Distribution = .compact(spacing: 20)
    var tint: ((Value) -> Color)? = { _ in .primary }
    let title: (Value) -> String

    @Namespace private var namespace

    var body: some View {
        switch distribution {
        case .compact(let spacing):
            HStack(spacing: spacing) {
                segments
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .justified:
            JustifiedLayout {
                segments
            }
            .frame(maxWidth: .infinity)
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

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var selection = Period.today

    VStack(spacing: 24) {
        SegmentStrip(selection: $selection, distribution: .justified, title: \.shortTitle)
        SegmentStrip(selection: $selection, title: \.shortTitle)
    }
    .padding()
}
