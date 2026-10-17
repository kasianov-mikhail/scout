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
                let window = DateInterval(start: payload.timeStampBegin, end: max(payload.timeStampBegin, payload.timeStampEnd))

                for diagnostic in payload.crashDiagnostics ?? [] {
                    do {
                        store(crash: try MetricKitCrash(diagnostic: diagnostic, window: window))
                    } catch {
                        print("Failed to read a MetricKit crash: \(error)")
                    }
                }
            }
        }

        private func store(crash: MetricKitCrash) {
            persistentContainer.performBackgroundTask { [installID] context in
                context.mergePolicy = NSMergePolicy.scout
                do {
                    try logMetricKitCrash(crash: crash, installID: installID, context: context)
                } catch {
                    print("Failed to save a MetricKit crash: \(error)")
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
