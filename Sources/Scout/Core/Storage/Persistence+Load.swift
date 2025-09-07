//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSPersistentContainer {
    func loadPersistentStores() throws {
        var captured: Error?
        loadPersistentStores { _, error in
            captured = error
        }
        if let captured {
            throw captured
        }
    }
}
