//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

extension Data {
    init(fixture: String) throws {
        let url = try #require(Bundle.module.url(forResource: fixture, withExtension: nil, subdirectory: "Fixtures"))
        try self.init(contentsOf: url)
    }
}

extension UUID {
    static let fixture = UUID(uuidString: "415BEADB-FB4D-3A0B-81CB-C279DAE37B0E")!
}
