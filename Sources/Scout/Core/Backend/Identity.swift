//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

struct Identity: Sendable {
    let install: UUID
    let launch: UUID
    let device: UUID
    let session: Protected<UUID>
}

@MainActor
extension Identity {
    func bootstrapLifecycle() async throws {
        installExceptionHandler(identity: self)
        installSignalHandler(identity: self)
        installHangHandler(identity: self)

        await CrashArchive.system.flush(deviceID: device)
        await HangArchive.system.flush(deviceID: device)

        try await persistentContainer.performBackgroundTasks(
            { try SessionObject.completeStale(launchID: launch, in: $0) },
            { try LaunchObject.completeStale(launchID: launch, in: $0) },
        )

        try await persistentContainer.performBackgroundTasks(
            { try DeviceObject.trigger(deviceID: device, in: $0) },
            { try InstallObject.trigger(installID: install, deviceID: device, in: $0) },
            { try VersionObject.trigger(installID: install, launchID: launch, in: $0) },
            { try LaunchObject.trigger(launchID: launch, installID: install, in: $0) },
            { try SessionObject.trigger(session: session, launchID: launch, in: $0) },
            { try UserActivityObject.trigger(sessionID: session.current, in: $0) },
            { try VersionMarker.trigger(installID: install, in: $0) }
        )
    }
}

extension Identity {
    var table: ActionTable {
        ActionTable(actions: [
            AppLifecycle.willEnterForeground: {
                try await persistentContainer.performBackgroundTasks(
                    { try SessionObject.trigger(session: session, launchID: launch, in: $0) },
                    { try UserActivityObject.trigger(sessionID: session.current, in: $0) },
                    { try VersionMarker.trigger(installID: install, in: $0) }
                )
            },
            AppLifecycle.didEnterBackground: {
                try await persistentContainer.performBackgroundTasks(
                    { try SessionObject.complete(launchID: launch, in: $0) },
                    { try UserActivityObject.trigger(sessionID: session.current, in: $0) }
                )
            },
        ])
    }
}

extension NSPersistentContainer {
    fileprivate func performBackgroundTasks(_ tasks: @Sendable (NSManagedObjectContext) throws -> Void...) async throws {
        for task in tasks {
            try await performBackgroundTask(task)
        }
    }
}
