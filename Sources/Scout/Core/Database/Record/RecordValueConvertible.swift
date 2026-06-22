//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol RecordValueConvertible {
    init?(recordValue: RecordValue)

    var recordValue: RecordValue { get }
}

extension String: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .string(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .string(self) }
}

extension Int: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = Int(value)
    }

    var recordValue: RecordValue { .int(Int64(self)) }
}

extension Int64: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .int(self) }
}

extension Double: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .double(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .double(self) }
}

extension Date: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .date(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .date(self) }
}

extension Data: RecordValueConvertible {
    init?(recordValue: RecordValue) {
        guard case .bytes(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .bytes(self) }
}

extension Array: RecordValueConvertible where Element == String {
    init?(recordValue: RecordValue) {
        guard case .strings(let value) = recordValue else { return nil }
        self = value
    }

    var recordValue: RecordValue { .strings(self) }
}
