//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

final class ChangeSignal: ObservableObject {
    @Published private(set) var generation = 0

    func bump() {
        generation += 1
    }
}

extension EnvironmentValues {
    @Entry var changes = ChangeSignal()
    @Entry var pollInterval: Duration = .seconds(30)
}
