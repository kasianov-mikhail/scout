//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct InfoChip: View {
    let systemImage: String
    let text: String
    var color: Color = .secondary
    var monospaced: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage).imageScale(.small).foregroundStyle(color)
            Text(verbatim: text).monospaced(monospaced)
        }
        .font(.footnote)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            ZStack(alignment: .leading) {
                Color.gray.opacity(0.12)
                color.frame(width: 3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    FlowLayout(spacing: 6) {
        InfoChip(systemImage: "iphone", text: "iPhone16,1", color: .blue)
        InfoChip(systemImage: "gearshape", text: "iOS 17.4", color: .indigo)
        InfoChip(systemImage: "globe", text: "en-US", color: .teal, monospaced: true)
        InfoChip(systemImage: "airplane", text: "TestFlight", color: .orange)
        InfoChip(systemImage: "tag", text: "v2.3.1 (412)", color: .green, monospaced: true)
    }
    .padding()
}
