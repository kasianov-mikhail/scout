# Incidents

Scout records two kinds of incidents: crashes and hangs. This page lists every failure an iOS or macOS app can hit, whether Scout captures it, and how.

| Incident | Status | Detected by | How it's captured |
| --- | --- | --- | --- |
| Uncaught Objective-C exception | ✅ Implemented | Exception handler | `NSSetUncaughtExceptionHandler` writes the exception name, reason, and `callStackSymbols` to a file. The next launch saves it as a crash. |
| Fatal signal: `SIGABRT`, `SIGSEGV`, `SIGBUS`, `SIGFPE`, `SIGILL`, `SIGTRAP` | ✅ Implemented | Signal handler | An async-signal-safe handler walks the frame pointers and writes raw return addresses. The next launch symbolicates them with `dladdr`. Covers Swift `fatalError`, force unwraps, and C++ `std::terminate`. |
| Main thread blocked for 3 s or more | ✅ Implemented | Hang monitor | A background queue pings the main thread every second. After 3 s it records a hang with the main thread's backtrace. |
| Main thread blocked for 8 s or more | ✅ Implemented | Hang monitor | The same monitor records a second, critical hang named "Watchdog Termination Imminent". |
| Crash the in-process handlers miss: watchdog kill, other `SIGKILL`, stack overflow | ✅ Implemented | MetricKit | MetricKit's `MXCrashDiagnostic`, delivered on a later launch. Linked to the crashed launch by its process ID. Frames are binary offsets, and the time is a window. |
| Memory-limit termination (jetsam) | 📋 Planned | MetricKit | Daily counts from MetricKit's `MXAppExitMetric`. The system leaves no stack trace for it. |
| Other terminations: background task timeout, locked file, CPU limit | 📋 Planned | MetricKit | Daily counts from MetricKit's `MXAppExitMetric`. |
| CPU exception | 📋 Planned | MetricKit | MetricKit's `MXCPUExceptionDiagnostic`, with a stack trace. |
| Disk write exception | 📋 Planned | MetricKit | MetricKit's `MXDiskWriteExceptionDiagnostic`, with a stack trace. |
| Memory exception | 📋 Planned | MetricKit | MetricKit's `MemoryExceptionDiagnostic`. Available only in the iOS 27 API. |
| Slow launch | 📋 Planned | MetricKit | MetricKit's `MXAppLaunchDiagnostic` (iOS 16+) and the daily launch-time histograms. |
| Hang reported by MetricKit | ⏸ Not planned | MetricKit | `MXHangDiagnostic` mostly repeats what the hang monitor already records. |
