//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logCrash(_ crash: CrashInfo, id: UUID = UUID(), deviceID: UUID, context: NSManagedObjectContext) throws {
    try logIncident(
        crash,
        id: id,
        deviceID: deviceID,
        idKey: "crashID",
        markerName: MarkerEntry.crashName,
        context: context
    ) { (entry: CrashEntry, session) in
        entry.session = session
    }
}
