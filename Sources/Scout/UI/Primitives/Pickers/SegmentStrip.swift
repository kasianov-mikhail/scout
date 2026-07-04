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
    var tint: (Value) -> Color = { _ in .blue }
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
            if value == selection {
                selected(value)
            } else {
                unselected(value)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selection)
    }

    private func selected(_ value: Value) -> some View {
        Text(title(value).uppercased())
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(tint(value))
                    .frame(height: 2)
                    .matchedGeometryEffect(id: "indicator", in: namespace)
            }
            .contentShape(.rect)
    }

    private func unselected(_ value: Value) -> some View {
        Text(title(value).uppercased())
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .onTapGesture {
                selection = value
            }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var selection = Period.today

    VStack(spacing: 24) {
        SegmentStrip(selection: $selection, distribution: .justified, title: \.shortTitle)
        SegmentStrip(selection: $selection, distribution: .compact(spacing: 12), title: \.shortTitle)
    }
    .padding()
}
