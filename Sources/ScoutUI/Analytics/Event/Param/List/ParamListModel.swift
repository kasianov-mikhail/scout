//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

@MainActor
final class ParamListModel: ObservableObject {
    let raw: ParamRaw

    init(items: [ParamProvider.Item]) {
        raw = ParamRaw(items: items)
    }
}
