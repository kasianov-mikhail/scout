//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension Backend {
    func deliver<T: DeliverableEntry>(_ type: T.Type, in context: NSManagedObjectContext, log: FailureLog) async {
        do {
            try await RecordSender<T>(backend: self).deliver(in: context)
        } catch is CancellationError {
            // A cancelled pass leaves the records pending for the next one.
        } catch let error as any TransientFailure where error.isTransient {
            report(failure: error, log: log)
        } catch {
            print("Failed to deliver \(type) to backend \(id): \(error)")
        }
    }

    func report(failure: any TransientFailure, log: FailureLog) {
        guard let misconfiguration = failure.misconfiguration else {
            return
        }
        log.printOnce(message: "Scout can't deliver to backend \(id): \(misconfiguration) (\(failure.localizedDescription)). Records stay pending until this is fixed.")
    }
}
