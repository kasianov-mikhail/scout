//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#if canImport(MetricKit)
    import MetricKit

    extension MetricKitReport {
        init(payload: MXMetricPayload) {
            let exits = payload.applicationExitMetrics.map {
                MetricKitExits(foreground: $0.foregroundExitData.counts, background: $0.backgroundExitData.counts)
            }
            self.init(
                readings: (exits?.readings ?? []) + MetricKitPerformance(payload: payload).readings,
                appVersion: payload.latestApplicationVersion,
                window: DateInterval(reportFrom: payload.timeStampBegin, to: payload.timeStampEnd)
            )
        }
    }

    extension MetricKitPerformance {
        fileprivate init(payload: MXMetricPayload) {
            self.init(
                launches: payload.applicationLaunchMetrics.map { [Bucket](histogram: $0.histogrammedTimeToFirstDraw) } ?? [],
                hangs: payload.applicationResponsivenessMetrics.map { [Bucket](histogram: $0.histogrammedApplicationHangTime) } ?? [],
                foregroundSeconds: payload.applicationTimeMetrics?.cumulativeForegroundTime.converted(to: .seconds).value ?? 0,
                peakMemoryMegabytes: payload.memoryMetrics?.peakMemoryUsage.converted(to: .megabytes).value
            )
        }
    }

    extension [MetricKitPerformance.Bucket] {
        fileprivate init(histogram: MXHistogram<UnitDuration>) {
            self = histogram.bucketEnumerator.allObjects.compactMap { $0 as? MXHistogramBucket<UnitDuration> }.map {
                MetricKitPerformance.Bucket(
                    start: $0.bucketStart.converted(to: .milliseconds).value,
                    end: $0.bucketEnd.converted(to: .milliseconds).value,
                    count: $0.bucketCount
                )
            }
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
#endif
