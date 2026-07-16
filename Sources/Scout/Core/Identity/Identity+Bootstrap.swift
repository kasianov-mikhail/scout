//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@MainActor
extension Identity {
    func bootstrap() async throws {
        installExceptionHandler(identity: self)
        installSignalHandler(identity: self)
        installHangHandler(identity: self)

        await CrashArchive.system.flush(deviceID: device)
        await HangArchive.system.flush(deviceID: device)

        try await persistentContainer.run(
            SessionEntry.Recovery(launchID: launch),
            LaunchEntry.Recovery(launchID: launch)
        )

        try await persistentContainer.run(
            DeviceEntry.Trigger(deviceID: device),
            InstallEntry.Trigger(installID: install, deviceID: device),
            VersionEntry.Trigger(installID: install, launchID: launch),
            LaunchEntry.Trigger(launchID: launch, installID: install),
            SessionEntry.Trigger(session: session, launchID: launch),
            MarkerEntry.Trigger(installID: install)
        )
    }
}
