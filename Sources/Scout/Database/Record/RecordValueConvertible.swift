//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package protocol RecordValueConvertible {
    init?(recordValue: RecordValue)

    var recordValue: RecordValue { get }
}

extension String: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .string(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .string(self) }
}

extension Int: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = Int(value)
    }

    package var recordValue: RecordValue { .int(Int64(self)) }
}

extension Int64: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .int(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .int(self) }
}

extension Double: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .double(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .double(self) }
}

extension Date: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .date(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .date(self) }
}

extension Data: RecordValueConvertible {
    package init?(recordValue: RecordValue) {
        guard case .bytes(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .bytes(self) }
}

extension Array: RecordValueConvertible where Element == String {
    package init?(recordValue: RecordValue) {
        guard case .strings(let value) = recordValue else { return nil }
        self = value
    }

    package var recordValue: RecordValue { .strings(self) }
}
