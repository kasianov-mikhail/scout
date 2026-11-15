//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct SectionNote: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.scoutCaption)
            .foregroundStyle(Color.textMuted)
    }
}

#Preview {
    SectionNote(text: "kept on day 7")
}
