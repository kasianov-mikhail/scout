//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

// Plain object-trump resolution lets a bare duplicate insert blank the
// attributes it never set, so a racing `linkedSession` row would erase a
// filled one. Backfilling nils from the other side of the conflict first
// keeps every populated value while the trump merge still dedupes the rows.
final class ScoutMergePolicy: NSMergePolicy {
    init() {
        super.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }

    override func resolve(constraintConflicts conflicts: [NSConstraintConflict]) throws {
        for conflict in conflicts {
            let donors = [conflict.databaseObject].compactMap(\.self) + conflict.conflictingObjects

            for object in conflict.conflictingObjects {
                backfill(object, from: donors)
            }
        }

        try super.resolve(constraintConflicts: conflicts)
    }

    private func backfill(_ object: NSManagedObject, from donors: [NSManagedObject]) {
        var keys = Array(object.entity.attributesByName.keys)
        keys += object.entity.relationshipsByName.filter { !$0.value.isToMany }.map(\.key)

        for key in keys where object.value(forKey: key) == nil {
            for donor in donors where donor !== object {
                if let value = donor.value(forKey: key) {
                    object.setValue(value, forKey: key)
                    break
                }
            }
        }
    }
}

extension NSMergePolicy {
    nonisolated(unsafe) static let scout: NSMergePolicy = ScoutMergePolicy()
}
