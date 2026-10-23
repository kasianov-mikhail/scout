//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

func makeQueuedRuntime() -> Runtime {
    let runtime = Runtime(backends: Runtime.stub.backends, identity: .stub, dispatcher: Runtime.stub.dispatcher)
    runtime.pendingWrites.mutate { _ = $0.append { _ in } }
    return runtime
}

extension Runtime {
    @MainActor
    func flushedContext() throws -> NSManagedObjectContext {
        let context = NSManagedObjectContext.inMemoryContext()
        for write in drainPendingWrites() {
            try write(context)
        }
        return context
    }
}
