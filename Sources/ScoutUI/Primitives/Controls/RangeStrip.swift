//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RangeStrip<Value: Hashable>: View {
    @Binding var selection: Value

    let ranges: [Value]
    let title: (Value) -> String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(ranges, id: \.self) { range in
                    Button {
                        selection = range
                    } label: {
                        Text(verbatim: title(range))
                            .font(.listTitle)
                            .foregroundStyle(range == selection ? Color.primary : Color.pending)
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
    RangeStrip(selection: .constant(IncidentRange.week), ranges: IncidentRange.allCases, title: \.title)
        .padding(.vertical)
}
