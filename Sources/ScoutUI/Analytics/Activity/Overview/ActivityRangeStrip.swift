//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityRangeStrip: View {
    @Binding var selection: ActivityRange

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(ActivityRange.allCases) { range in
                    Button {
                        selection = range
                    } label: {
                        Text(verbatim: range.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
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
    ActivityRangeStrip(selection: .constant(.month))
        .padding(.vertical)
}
