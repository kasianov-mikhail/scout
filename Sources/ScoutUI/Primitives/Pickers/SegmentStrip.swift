//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
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
    @State private var indicator: Value?

    var body: some View {
        distributed
            .onAppear {
                if indicator == nil {
                    indicator = selection
                }
            }
            .onChange(of: selection) { newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    indicator = newValue
                }
            }
            .hapticFeedback(.selection, trigger: selection)
    }

    @ViewBuilder
    private var distributed: some View {
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

    private var segments: some View {
        ForEach(values, id: \.self) { value in
            Text(title(value).uppercased())
                .font(.system(size: 14, weight: value == selection ? .bold : .medium))
                .foregroundStyle(value == selection ? .primary : .secondary)
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    if value == indicator {
                        Capsule()
                            .fill(tint(value))
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "indicator", in: namespace)
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
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
        SegmentStrip(selection: $selection, distribution: .compact(spacing: 12), title: \.shortTitle)
    }
    .padding()
}
