//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A generic class that conforms to `ObservableObject` and wraps a value of type `T`.
///
/// This class provides a way to observe changes to the wrapped value using SwiftUI's
/// `@Published` property wrapper, making it suitable for use in SwiftUI views.
/// The primary use case for this class is to wrap a value that is not a reference type
/// and share it across multiple views, allowing changes to the value to be observed.
///
/// - Parameter T: The type of the value to be wrapped.
///
class Box<T>: ObservableObject {

    /// The wrapped value
    @Published var value: T

    /// Initializes a new instance of `Box` with the given value.
    ///
    /// - Parameter value: The initial value to be wrapped.
    ///
    init(_ value: T) {
        self.value = value
    }
}

// MARK: - Equatable

extension Box: Equatable where T: Equatable {
    static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: -

extension Box: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(value) of type \(T.self)"
    }
}
