//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import UserNotifications

@testable import ScoutUI

private let authorizationStatuses: [(UNAuthorizationStatus, Bool)] = {
    var statuses: [(UNAuthorizationStatus, Bool)] = [
        (.denied, true),
        (.authorized, false),
        (.provisional, false),
        (.notDetermined, false),
    ]
    #if !os(macOS)
        statuses.append((.ephemeral, false))
    #endif
    return statuses
}()

struct NotificationPermissionTests {
    @Test("Only a denied center reports the permission as denied", arguments: authorizationStatuses)
    func isDenied(status: UNAuthorizationStatus, denied: Bool) async {
        let center = NotificationCenterStub()
        center.status = status

        #expect(await NotificationPermission(center: center).isDenied == denied)
    }

    @Test("An undetermined center is asked for authorization once")
    func undetermined() async {
        let center = NotificationCenterStub()
        center.status = .notDetermined
        let permission = NotificationPermission(center: center)

        await permission.requestIfUndetermined()
        await permission.requestIfUndetermined()

        #expect(center.authorizationRequests == 1)
    }

    @Test("A center that already answered is not asked again", arguments: [UNAuthorizationStatus.authorized, .denied])
    func determined(status: UNAuthorizationStatus) async {
        let center = NotificationCenterStub()
        center.status = status

        await NotificationPermission(center: center).requestIfUndetermined()

        #expect(center.authorizationRequests == 0)
    }
}
