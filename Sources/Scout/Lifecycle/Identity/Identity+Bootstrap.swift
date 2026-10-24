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
        installHangHandler()

        let crashes = IncidentArchive.crash
        let hangs = IncidentArchive.hang
        crashes.convertRawReports()
        await crashes.flush(deviceID: device)
        await hangs.flush(deviceID: device)

        let openLaunchIDs = crashes.launchIDs.union(hangs.launchIDs).union([launch])
        try await persistentContainer.run(recoveryCommands(openLaunchIDs: openLaunchIDs))
        try await persistentContainer.run(startupCommands())

        installMetricKitReceiver()
    }

    private func recoveryCommands(openLaunchIDs: Set<UUID>) -> [any Command] {
        [
            SessionEntry.Recovery(openLaunchIDs: openLaunchIDs),
            ScreenEntry.Recovery(openLaunchIDs: openLaunchIDs),
            LaunchEntry.Recovery(openLaunchIDs: openLaunchIDs),
        ]
    }

    func startupCommands(bundle: Bundle = .main) -> [any Command] {
        [
            DeviceEntry.Trigger(deviceID: device),
            InstallEntry.Trigger(installID: install, deviceID: device),
            LaunchEntry.Trigger(launchID: launch, installID: install, processID: ProcessInfo.processInfo.processIdentifier),
            VersionEntry.Trigger(installID: install, launchID: launch, bundle: bundle),
            FirstSeenEntry.Trigger(installID: install),
        ]
    }
}
