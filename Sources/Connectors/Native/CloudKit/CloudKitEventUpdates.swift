//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Combine
import Foundation
import OSLog
import Scout

let cloudKitEventSubscriptionPrefix = "scout.events.v1."

protocol CloudKitSubscriptions: Sendable {
    func subscription(for subscriptionID: String) async throws -> CKSubscription
    func save(_ subscription: CKSubscription) async throws -> CKSubscription
}

extension CKDatabase: CloudKitSubscriptions {}

actor CloudKitEventUpdates: EventUpdatesSource {
    private let containerID: String

    private let database: any CloudKitSubscriptions
    private let logger = Logger(subsystem: "Scout", category: "CloudKit subscriptions")

    private var observers: [UUID: AsyncStream<Void>.Continuation] = [:]
    private var registration: Task<Void, Never>?
    private var pending: Task<Void, Never>?
    private var accountChanges: AnyCancellable?

    init(container: CKContainer) throws {
        guard let id = container.containerIdentifier else {
            throw Backend.UnidentifiedContainerError()
        }
        self.init(containerID: id, database: container.publicCloudDatabase)
    }

    init(containerID: String, database: any CloudKitSubscriptions) {
        self.containerID = containerID
        self.database = database
    }

    func changes() async -> AsyncStream<Void> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        observers[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeObserver(id: id) }
        }

        observeAccountChanges()
        registerIfNeeded()
        return stream
    }

    func invalidate() async {
        guard !observers.isEmpty else {
            return
        }
        registerIfNeeded()
        guard pending == nil else {
            return
        }
        pending = Task {
            try? await Task.sleep(for: .seconds(1))
            pending = nil
            for observer in observers.values {
                observer.yield(())
            }
        }
    }

    private func observeAccountChanges() {
        guard accountChanges == nil else {
            return
        }
        accountChanges = NotificationCenter.default.publisher(for: .CKAccountChanged)
            .sink { @Sendable [weak self] _ in
                Task { await self?.resetRegistration() }
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
            do {
                _ = try await database.save(makeEventSubscription(id: subscriptionID))
            } catch let error as CKError where error.code == .serverRejectedRequest {
                _ = try? await database.subscription(for: subscriptionID)
            }
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

    private func makeEventSubscription(id: String) -> CKQuerySubscription {
        let subscription = CKQuerySubscription(
            recordType: "Entity",
            predicate: NSPredicate(format: "s_00 == %@", Event.recordType),
            subscriptionID: id,
            options: [.firesOnRecordCreation]
        )
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        return subscription
    }
}
