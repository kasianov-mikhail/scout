//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(BackgroundTasks)
    import Foundation
    import Scout

    /// Host-app entry point for background alert evaluation.
    ///
    /// Call ``registerBackgroundRefresh(backends:)`` before the app finishes
    /// launching and ``scheduleBackgroundRefresh()`` whenever the app moves to
    /// the background. The host's Info.plist must list ``taskIdentifier`` under
    /// `BGTaskSchedulerPermittedIdentifiers` and include the `fetch` background
    /// mode.
    ///
    @MainActor
    public enum ScoutAlerts {
        /// The background task identifier host apps whitelist in their Info.plist.
        public static var taskIdentifier: String {
            AlertRefreshScheduler.taskIdentifier
        }

        private static var scheduler: AlertRefreshScheduler?

        /// Hooks alert evaluation into the background task scheduler.
        ///
        /// Must be called before the app finishes launching; the system rejects
        /// later registrations.
        ///
        public static func registerBackgroundRefresh(backends: [Backend]) {
            let provider = AlertProvider(notifier: AlertNotifier())
            let refresher = AlertRefreshScheduler {
                await refresh(provider: provider, backends: backends)
            }

            refresher.register()
            scheduler = refresher
        }

        /// Requests a background refresh, skipped while no alert rules exist.
        public static func scheduleBackgroundRefresh() {
            guard AlertStore().rules.count > 0 else { return }
            scheduler?.schedule()
        }

        private static func refresh(provider: AlertProvider, backends: [Backend]) async {
            guard let backend = backends.active else { return }
            _ = try? await provider.fetch(in: backend.cachedDatabase)
        }
    }
#endif
