# Incidents

Scout records crashes, hangs, and resource exceptions as incidents and collects daily app exit counts and performance metrics. This page lists every failure an iOS or macOS app can hit, whether Scout captures it, and how.

| Incident | Status | Detected by |
| --- | --- | --- |
| Uncaught Objective-C exception | ✅ Implemented | Exception handler |
| Fatal signal: `SIGABRT`, `SIGSEGV`, `SIGBUS`, `SIGFPE`, `SIGILL`, `SIGTRAP` | ✅ Implemented | Signal handler |
| Main thread blocked for 3 s or more | ✅ Implemented | Hang monitor |
| Main thread blocked for 8 s or more | ✅ Implemented | Hang monitor |
| Crash the in-process handlers miss: watchdog kill, other `SIGKILL`, stack overflow | ✅ Implemented | MetricKit |
| Memory-limit termination (jetsam) | ✅ Implemented | MetricKit |
| Other terminations: background task timeout, locked file, CPU limit | ✅ Implemented | MetricKit |
| CPU exception | ✅ Implemented | MetricKit |
| Disk write exception | ✅ Implemented | MetricKit |
| Memory exception | ⛔ Not available | None: MetricKit has no such diagnostic, so memory-limit terminations count as exits |
| Slow launch | ✅ Implemented | MetricKit |
| Hang reported by MetricKit | ⏸ Not planned | MetricKit |
