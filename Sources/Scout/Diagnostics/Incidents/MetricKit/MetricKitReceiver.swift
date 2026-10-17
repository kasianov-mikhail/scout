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
                if let exits = MetricKitExits(payload: payload) {
                    save(subject: "MetricKit exits") { [installID] context in
                        try logMetricKitExits(exits: exits, installID: installID, context: context)
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

    extension MetricKitCrash {
        fileprivate init(diagnostic: MXCrashDiagnostic, window: DateInterval) throws {
            self.init(
                exceptionType: diagnostic.exceptionType?.intValue,
                signal: diagnostic.signal?.int32Value,
                terminationReason: diagnostic.terminationReason,
                exception: Exception(diagnostic: diagnostic),
                appVersion: diagnostic.applicationVersion,
                processID: diagnostic.processID,
                window: window,
                frames: try MetricKitStackTree(json: diagnostic.callStackTree.jsonRepresentation()).crashedFrames
            )
        }
    }

    extension MetricKitExits {
        fileprivate init?(payload: MXMetricPayload) {
            guard let metric = payload.applicationExitMetrics else {
                return nil
            }
            self.init(
                foreground: metric.foregroundExitData.counts,
                background: metric.backgroundExitData.counts,
                appVersion: payload.latestApplicationVersion,
                window: DateInterval(reportFrom: payload.timeStampBegin, to: payload.timeStampEnd)
            )
        }
    }

    extension DateInterval {
        fileprivate init(reportFrom begin: Date, to end: Date) {
            self.init(start: begin, end: max(begin, end))
        }
    }

    extension MXForegroundExitData {
        fileprivate var counts: [ExitReason: Int] {
            [
                .normal: cumulativeNormalAppExitCount,
                .memoryLimit: cumulativeMemoryResourceLimitExitCount,
                .watchdog: cumulativeAppWatchdogExitCount,
                .badAccess: cumulativeBadAccessExitCount,
                .illegalInstruction: cumulativeIllegalInstructionExitCount,
                .abnormal: cumulativeAbnormalExitCount,
            ]
        }
    }

    extension MXBackgroundExitData {
        fileprivate var counts: [ExitReason: Int] {
            [
                .normal: cumulativeNormalAppExitCount,
                .memoryPressure: cumulativeMemoryPressureExitCount,
                .memoryLimit: cumulativeMemoryResourceLimitExitCount,
                .cpuLimit: cumulativeCPUResourceLimitExitCount,
                .watchdog: cumulativeAppWatchdogExitCount,
                .badAccess: cumulativeBadAccessExitCount,
                .illegalInstruction: cumulativeIllegalInstructionExitCount,
                .abnormal: cumulativeAbnormalExitCount,
                .lockedFile: cumulativeSuspendedWithLockedFileExitCount,
                .taskTimeout: cumulativeBackgroundTaskAssertionTimeoutExitCount,
            ]
        }
    }

    extension MetricKitCrash.Exception {
        fileprivate init?(diagnostic: MXCrashDiagnostic) {
            guard #available(iOS 17, macOS 14, *), let reason = diagnostic.exceptionReason else {
                return nil
            }
            self.init(name: reason.exceptionName, message: reason.composedMessage)
        }
    }

    extension MXCrashDiagnostic {
        fileprivate var processID: Int32? {
            if #available(iOS 17, macOS 14, *) {
                metaData.pid
            } else {
                nil
            }
        }
    }
#else
    func installMetricKitReceiver(identity: Identity) {}
#endif
