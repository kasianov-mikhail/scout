//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(MetricKit)
    import MetricKit

    extension MetricKitCrash {
        init(diagnostic: MXCrashDiagnostic, window: DateInterval) throws {
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
#endif
