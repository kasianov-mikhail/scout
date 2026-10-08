//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 18, macOS 15, *)
@Model
final class CachedSpan {
    var fingerprint: String
    var lowerDate: Date
    var upperDate: Date

    init(fingerprint: String, lowerDate: Date, upperDate: Date) {
        self.fingerprint = fingerprint
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }
}
