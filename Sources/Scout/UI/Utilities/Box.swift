//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class Box<T>: ObservableObject {
    @Published var value: T

    init(_ value: T) {
        self.value = value
    }
}
