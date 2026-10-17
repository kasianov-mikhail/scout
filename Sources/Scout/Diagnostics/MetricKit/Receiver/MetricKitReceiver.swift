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

    extension Identity {
        func installMetricKitReceiver() {
            guard receiver == nil else {
                return
            }

            let installed = MetricKitReceiver(installID: install)
            MXMetricManager.shared.add(installed)
            receiver = installed
        }
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
                    save(subject: "a MetricKit crash") { try MetricKitCrash(diagnostic: diagnostic, window: window) }
                }
                for diagnostic in payload.cpuExceptionDiagnostics ?? [] {
                    save(subject: "a MetricKit CPU exception") { try MetricKitResource(diagnostic: diagnostic, window: window) }
                }
                for diagnostic in payload.diskWriteExceptionDiagnostics ?? [] {
                    save(subject: "a MetricKit disk write exception") { try MetricKitResource(diagnostic: diagnostic, window: window) }
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

        private func save(subject: String, incident: () throws -> any MetricKitIncident) {
            do {
                let incident = try incident()
                save(subject: subject) { [installID] context in
                    try incident.log(installID: installID, context: context)
                }
            } catch {
                print("Failed to read \(subject): \(error)")
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

    extension MXDiagnostic {
        var processID: Int32? {
            if #available(iOS 17, macOS 14, *) {
                metaData.pid
            } else {
                nil
            }
        }
    }

    extension DateInterval {
        init(reportFrom begin: Date, to end: Date) {
            self.init(start: begin, end: max(begin, end))
        }
    }
#else
    extension Identity {
        func installMetricKitReceiver() {}
    }
#endif
