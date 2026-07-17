//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension TimeInterval {
    package static let minute: TimeInterval = 60
    package static let hour: TimeInterval = 3_600
    package static let day: TimeInterval = 86_400
    // Nominal spans for coarse formatting: a 30-day month and a 365-day year.
    package static let month: TimeInterval = 2_592_000
    package static let year: TimeInterval = 31_536_000
}
