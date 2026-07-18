//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol Command: Sendable {
    func execute(in context: NSManagedObjectContext) throws
}

extension NSPersistentContainer {
    func run(_ commands: any Command...) async throws {
        try await performBackgroundTask { context in
            for command in commands {
                try command.execute(in: context)
            }
        }
    }
}
