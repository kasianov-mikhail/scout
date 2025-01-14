//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RedactedText: View {
    let count: Int?

    var body: some View {
        if let count = count {
            Text(count == 0 ? "—" : "\(count)")
        } else {
            Redacted(length: 5)
        }
    }
}
