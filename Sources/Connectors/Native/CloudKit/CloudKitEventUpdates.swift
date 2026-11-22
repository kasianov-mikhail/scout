//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Combine
import OSLog
import Scout

let cloudKitEventSubscriptionPrefix = "scout.events.v1."

protocol CloudKitSubscriptions: Sendable {
    func subscription(for subscriptionID: String) async throws -> CKSubscription
    func save(_ subscription: CKSubscription) async throws -> CKSubscription
}

extension CKDatabase: CloudKitSubscriptions {}

actor CloudKitEventUpdates: EventChangeSource {
    let containerID: String
    private let database: any CloudKitSubscriptions
    private let logger = Logger(subsystem: "Scout", category: "CloudKit subscriptions")

    private var observers: [UUID: AsyncStream<Void>.Continuation] = [:]
    private var isInvalidationPending = false
    private var registration: Task<Void, Never>?
    private var accountChanges: AnyCancellable?

    init(container: CKContainer) throws {
        guard let containerID = container.containerIdentifier else {
            throw UnidentifiedContainerError()
        }
        self.init(containerID: containerID, database: container.publicCloudDatabase)
    }

    init(containerID: String, database: any CloudKitSubscriptions) {
        self.containerID = containerID
        self.database = database
    }

    func observe() -> AsyncStream<Void> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        observers[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id: id) }
        }

        if accountChanges == nil {
            accountChanges = NotificationCenter.default.publisher(for: .CKAccountChanged)
                .sink { @Sendable [weak self] _ in
                    Task { await self?.resetRegistration() }
                }
        }
        registerIfNeeded()
        return stream
    }

    func invalidate() {
        guard !observers.isEmpty, !isInvalidationPending else {
            return
        }
        isInvalidationPending = true

        Task {
            try? await Task.sleep(for: .seconds(1))
            isInvalidationPending = false
            for observer in observers.values {
                observer.yield(())
            }
        }
    }

    private func registerIfNeeded() {
        guard registration == nil else {
            return
        }
        registration = Task {
            do {
                try await ensureSubscription()
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                registration = nil
                logger.error("Unable to register the event subscription: \(error.localizedDescription)")
            }
        }
    }

    private func ensureSubscription() async throws {
        let subscriptionID = cloudKitEventSubscriptionPrefix + containerID
        do {
            _ = try await database.subscription(for: subscriptionID)
        } catch let error as CKError where error.code == .unknownItem {
            try Task.checkCancellation()
            _ = try await database.save(makeEventSubscription(id: subscriptionID))
        }
    }

    private func resetRegistration() {
        registration?.cancel()
        registration = nil
        if !observers.isEmpty {
            registerIfNeeded()
        }
    }

    private func removeObserver(id: UUID) {
        observers[id] = nil
    }
}

private struct UnidentifiedContainerError: LocalizedError {
    let errorDescription: String? = "The CloudKit container carries no identifier"
}

private func makeEventSubscription(id: String) -> CKQuerySubscription {
    // scout-db's Entity envelope stores the logical record type in s_00.
    let subscription = CKQuerySubscription(
        recordType: "Entity",
        predicate: NSPredicate(format: "s_00 == %@", Event.recordType),
        subscriptionID: id,
        options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
    )
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true
    subscription.notificationInfo = notificationInfo
    return subscription
}
