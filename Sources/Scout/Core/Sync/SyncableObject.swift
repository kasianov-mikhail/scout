//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SyncableObject)
class SyncableObject: IDObject {
    class var isLocalOnly: Bool { false }

    @NSManaged var deliveries: Set<SyncDelivery>

    func delivery(for backendID: String) -> SyncDelivery? {
        deliveries.first { $0.backendID == backendID }
    }
}

@objc(SyncDelivery)
final class SyncDelivery: NSManagedObject {
    static let maxAttempts = 10

    @NSManaged var backendID: String
    @NSManaged var progressPrimitive: Int16
    @NSManaged var attempts: Int16
    @NSManaged var object: SyncableObject

    var progress: Progress {
        get { Progress(rawValue: Int(progressPrimitive)) }
        set { progressPrimitive = Int16(newValue.rawValue) }
    }

    struct Progress: OptionSet, Sendable {
        let rawValue: Int

        static let raw = Progress(rawValue: 1 << 0)
        // No longer planned; kept so rows persisted by the legacy matrix channel keep decoding.
        static let matrix = Progress(rawValue: 1 << 1)

        static let all: Progress = [.raw, .matrix]
    }
}

extension [SyncDelivery] {
    func complete(_ progress: SyncDelivery.Progress) {
        forEach { $0.progress.remove(progress) }
    }
}
