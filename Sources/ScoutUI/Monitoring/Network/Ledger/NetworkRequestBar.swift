//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct NetworkRequestBar: View {
    let requests: Int
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                if requests > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.networkTrack)
                        .frame(width: max(proxy.size.width * fraction, 4), height: 28)
                }

                Text(verbatim: requests.compact)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(.horizontal, 4)
            }
            .frame(width: proxy.size.width, height: 18)
        }
        .frame(height: 18)
    }
}
