//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct Header<Trailing: View>: View {
    let title: String

    @ViewBuilder let trailing: () -> Trailing

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(title.uppercased()).font(.callout.weight(.bold))

            Spacer()

            trailing()
        }
        .padding(.top, 12)
        .frame(height: 70)
    }
}

#Preview {
    InsetList {
        Header(title: "Section Title")
        Header(title: "Section Title") {
            AllButton {}
        }
    }
}
