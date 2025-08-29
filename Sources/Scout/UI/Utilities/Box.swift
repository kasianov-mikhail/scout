//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

class Box<T>: ObservableObject {
    @Published var value: T

    init(_ value: T) {
        self.value = value
    }
}

extension Box: Equatable where T: Equatable {
    static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.value == rhs.value
    }
}

extension Box: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(value) of type \(T.self)"
    }
}
