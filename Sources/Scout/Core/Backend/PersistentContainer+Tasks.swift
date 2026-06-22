//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSPersistentContainer {
    func performBackgroundTasks(_ tasks: @Sendable (NSManagedObjectContext) throws -> Void...) async throws {
        for task in tasks {
            try await performBackgroundTask(task)
        }
    }
}
