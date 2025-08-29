//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Error {
    /// Handles error by logging it to console
    func logError() {
        print(localizedDescription)
    }
    
    /// Creates a Message object for UI error display
    func toMessage() -> Message {
        Message(localizedDescription, level: .error)
    }
}