//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricRangeStrip: View {
    @Binding var selection: MetricRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .space20) {
                ForEach(MetricRange.allCases) { range in
                    Button {
                        selection = range
                    } label: {
                        Text(verbatim: range.title)
                            .font(.scoutNumberL)
                            .foregroundStyle(range == selection ? Color.textPrimary : Color.pending)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(range == selection ? .isSelected : [])
                }
            }
        }
        .mask(alignment: .trailing) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(.black)
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 56)
            }
        }
        .hapticFeedback(.selection, trigger: selection)
    }
}

#Preview {
    MetricRangeStrip(selection: .constant(.today))
        .padding(.vertical)
}
