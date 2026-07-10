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
            SessionObject.Recovery(launchID: launch),
            LaunchObject.Recovery(launchID: launch)
        )

        try await persistentContainer.run(
            DeviceObject.Trigger(deviceID: device),
            InstallObject.Trigger(installID: install, deviceID: device),
            VersionObject.Trigger(installID: install, launchID: launch),
            LaunchObject.Trigger(launchID: launch, installID: install),
            SessionObject.Trigger(session: session, launchID: launch),
            UserActivityObject.Trigger(session: session),
            VersionMarker.Trigger(installID: install)
        )
    }
}
