//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct Segment: Identifiable, Equatable {
    let label: String
    let count: Int
    let color: Color

    var id: String { label }
}
