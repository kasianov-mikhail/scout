//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EndpointSearchDetail: View {
    let name: String

    var body: some View {
        NetworkEndpointView(name: name, initialRange: .today)
    }
}
