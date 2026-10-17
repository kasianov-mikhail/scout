//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

func logHang(_ hang: HangInfo, id: UUID = UUID(), deviceID: UUID, context: NSManagedObjectContext) throws {
    try logIncident(
        hang,
        id: id,
        deviceID: deviceID,
        idKey: "hangID",
        markerName: MarkerEntry.hangName,
        context: context
    ) { (entry: HangEntry, session) in
        entry.session = session
        entry.duration = hang.duration
    }
}
