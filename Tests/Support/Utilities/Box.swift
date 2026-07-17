//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A mutable reference cell for observing side effects of `Sendable` closures in tests.
final class Box<T>: @unchecked Sendable {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
