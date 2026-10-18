//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct BinaryImagesSection: View {
    let images: [Backtrace.Image]

    var body: some View {
        if !images.isEmpty {
            Header(title: "Binary Images")

            ForEach(images, id: \.self) { image in
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: image.name)
                        .font(.caption)
                    Text(verbatim: image.uuid?.uuidString ?? "No UUID")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .monospaced()
            }
        }
    }
}

#Preview {
    InsetList {
        BinaryImagesSection(images: Backtrace.sample.images)
    }
}
