//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(MetricKit)
    import CoreData
    import MetricKit

    private nonisolated(unsafe) var receiver: MetricKitReceiver?

    func installMetricKitReceiver(identity: Identity) {
        guard receiver == nil else {
            return
        }

        let installed = MetricKitReceiver(installID: identity.install)
        MXMetricManager.shared.add(installed)
        receiver = installed
    }

    private final class MetricKitReceiver: NSObject, MXMetricManagerSubscriber {
        let installID: UUID

        init(installID: UUID) {
            self.installID = installID
        }

        func didReceive(_ payloads: [MXDiagnosticPayload]) {
            for payload in payloads {
                let window = DateInterval(reportFrom: payload.timeStampBegin, to: payload.timeStampEnd)

                for diagnostic in payload.crashDiagnostics ?? [] {
                    do {
                        let crash = try MetricKitCrash(diagnostic: diagnostic, window: window)
                        save(subject: "a MetricKit crash") { [installID] context in
                            try logMetricKitCrash(crash: crash, installID: installID, context: context)
                        }
                    } catch {
                        print("Failed to read a MetricKit crash: \(error)")
                    }
                }
            }
        }

        func didReceive(_ payloads: [MXMetricPayload]) {
            for payload in payloads {
                let report = MetricKitReport(payload: payload)
                if !report.readings.isEmpty {
                    save(subject: "a MetricKit report") { [installID] context in
                        try report.log(installID: installID, context: context)
                    }
                }
            }
        }

        private func save(subject: String, write: @escaping @Sendable (NSManagedObjectContext) throws -> Void) {
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.scout
                do {
                    try write(context)
                } catch {
                    print("Failed to save \(subject): \(error)")
                }
            }
        }
    }

    extension DateInterval {
        init(reportFrom begin: Date, to end: Date) {
            self.init(start: begin, end: max(begin, end))
        }
    }
#else
    func installMetricKitReceiver(identity: Identity) {}
#endif
