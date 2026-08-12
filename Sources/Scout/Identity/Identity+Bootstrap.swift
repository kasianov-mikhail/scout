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

        try await persistentContainer.run(recoveryCommands)
        try await persistentContainer.run(startupCommands())
    }

    private var recoveryCommands: [any Command] {
        [
            SessionEntry.Recovery(launchID: launch),
            LaunchEntry.Recovery(launchID: launch),
        ]
    }

    func startupCommands(bundle: Bundle = .main) -> [any Command] {
        [
            DeviceEntry.Trigger(deviceID: device),
            InstallEntry.Trigger(installID: install, deviceID: device),
            LaunchEntry.Trigger(launchID: launch, installID: install),
            VersionEntry.Trigger(installID: install, launchID: launch, bundle: bundle),
            SessionEntry.Trigger(session: session, launchID: launch, bundle: bundle),
            VisitEntry.Trigger(launchID: launch),
            MarkerEntry.Trigger(installID: install),
        ]
    }
}
