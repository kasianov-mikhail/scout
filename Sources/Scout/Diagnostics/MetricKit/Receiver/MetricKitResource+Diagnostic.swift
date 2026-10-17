//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(MetricKit)
    import MetricKit

    extension MetricKitResource {
        init(diagnostic: MXCPUExceptionDiagnostic, window: DateInterval) throws {
            self.init(
                kind: .cpu,
                amount: diagnostic.totalCPUTime.converted(to: .seconds).value,
                sampledSeconds: diagnostic.totalSampledTime.converted(to: .seconds).value,
                appVersion: diagnostic.applicationVersion,
                processID: diagnostic.processID,
                window: window,
                frames: try MetricKitStackTree(json: diagnostic.callStackTree.jsonRepresentation()).heaviestFrames
            )
        }

        init(diagnostic: MXDiskWriteExceptionDiagnostic, window: DateInterval) throws {
            self.init(
                kind: .diskWrite,
                amount: diagnostic.totalWritesCaused.converted(to: .bytes).value,
                sampledSeconds: nil,
                appVersion: diagnostic.applicationVersion,
                processID: diagnostic.processID,
                window: window,
                frames: try MetricKitStackTree(json: diagnostic.callStackTree.jsonRepresentation()).heaviestFrames
            )
        }
    }
#endif
