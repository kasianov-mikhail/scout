//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 3_600
    static let day: TimeInterval = 86_400
    // Nominal spans for coarse formatting: a 30-day month and a 365-day year.
    static let month: TimeInterval = 2_592_000
    static let year: TimeInterval = 31_536_000
}
