//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Provider {
    var error: Error? {
        result?.error
    }
}
extension Result {
    var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }
}
