# Changelog

## 3.0.0 — 2026-03-29

- Rewrite crash handler for ARM64 compatibility
- Fix duplicate crash reports for uncaught exceptions
- Fix infinite recursion in uncaught exception handler
- Chunk CloudKit write requests to respect 400-record limit
- Add CloudKit schema verification on startup
- Show iCloud unavailable warning in HomeView
- Upload individual records before matrix in sync engine
- Switch Core Data codegen to Manual/None
- Add swift-format linting to CI
- Add tests for telemetry, crash logging, metrics, queue dispatcher, and predicates
- Reorganize folder structure in Core/ and UI/
