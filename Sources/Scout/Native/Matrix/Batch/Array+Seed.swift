//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Array {
    func seed<Value>(_ keyPath: KeyPath<Element, Value?>) throws -> Value {
        guard let first else {
            throw SeedError.emptyArray
        }
        guard let value = first[keyPath: keyPath] else {
            throw SeedError.missingProperty(keyPath._kvcKeyPathString)
        }
        return value
    }

    enum SeedError: LocalizedError {
        case emptyArray
        case missingProperty(String?)

        var errorDescription: String? {
            switch self {
            case .emptyArray:
                "Cannot group objects. The array is empty."
            case .missingProperty(.some(let property)):
                "Cannot group objects. Missing property: \(property)."
            case .missingProperty:
                "Cannot group objects."
            }
        }
    }
}
