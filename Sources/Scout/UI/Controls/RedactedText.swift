//
// Copyright 2024 Mikhail Kasianov
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

struct Redacted: View {
    let length: Int

    var body: some View {
        Text(String(repeating: " ", count: length))
            .redacted(reason: .placeholder)
    }
}


#Preview {
    List {
        Redacted(length: 3)
        Redacted(length: 5)
        Redacted(length: 8)
    }
    .listStyle(.plain)
}
