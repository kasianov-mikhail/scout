//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@MainActor extension Backend {
    func deliver<T: DeliverableEntry>(_ type: T.Type, in context: NSManagedObjectContext) async {
        do {
            try await RecordSender<T>(backend: self).deliver(in: context)
        } catch is CancellationError {
            // A cancelled pass leaves the records pending for the next one.
        } catch let error as any TransientFailure where error.isTransient {
            // Offline or throttled: the next pass retries the same records.
        } catch {
            print("Failed to deliver \(type) to backend \(id): \(error)")
        }
    }
}
