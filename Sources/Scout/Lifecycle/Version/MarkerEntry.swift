//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(MarkerEntry)
package final class MarkerEntry: DateEntry {
    package static let installName = Version.installMarker
    package static let crashName = Version.crashMarker
    static let hangName = Version.hangMarker

    @NSManaged var appVersion: String?
    @NSManaged var markerID: UUID
    @NSManaged var name: String?
    @NSManaged var install: InstallEntry?
}
