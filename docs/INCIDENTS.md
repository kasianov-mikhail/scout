# Incidents

Scout records two kinds of incidents: crashes and hangs. This page lists every failure an iOS or macOS app can hit, whether Scout captures it, and how.

| Incident | Status | How it's captured |
| --- | --- | --- |
| Uncaught Objective-C exception | ✅ Implemented | `NSSetUncaughtExceptionHandler` writes the exception name, reason, and `callStackSymbols` to a file. The next launch saves it as a crash. |
| Fatal signal: `SIGABRT`, `SIGSEGV`, `SIGBUS`, `SIGFPE`, `SIGILL`, `SIGTRAP` | ✅ Implemented | An async-signal-safe handler walks the frame pointers and writes raw return addresses. The next launch symbolicates them with `dladdr`. Covers Swift `fatalError`, force unwraps, and C++ `std::terminate`. |
| Main thread blocked for 3 s or more | ✅ Implemented | A background queue pings the main thread every second. After 3 s it records a hang with the main thread's backtrace. |
| Main thread blocked for 8 s or more | ✅ Implemented | The same monitor records a second, critical hang named "Watchdog Termination Imminent". |
| Crash the in-process handlers miss: watchdog kill, other `SIGKILL`, stack overflow | 🔄 In review | MetricKit's `MXCrashDiagnostic`, delivered on a later launch. Linked to the crashed launch by its process ID. Frames are binary offsets, and the time is a window. |
| Memory-limit termination (jetsam) | 📋 Planned | Daily counts from MetricKit's `MXAppExitMetric`. The system leaves no stack trace for it. |
| Other terminations: background task timeout, locked file, CPU limit | 📋 Planned | Daily counts from MetricKit's `MXAppExitMetric`. |
| CPU exception | 📋 Planned | MetricKit's `MXCPUExceptionDiagnostic`, with a stack trace. |
| Disk write exception | 📋 Planned | MetricKit's `MXDiskWriteExceptionDiagnostic`, with a stack trace. |
| Memory exception | 📋 Planned | MetricKit's `MemoryExceptionDiagnostic`. Available only in the iOS 27 API. |
| Slow launch | 📋 Planned | MetricKit's `MXAppLaunchDiagnostic` (iOS 16+) and the daily launch-time histograms. |
| Hang reported by MetricKit | ⏸ Not planned | `MXHangDiagnostic` mostly repeats what the hang monitor already records. |
