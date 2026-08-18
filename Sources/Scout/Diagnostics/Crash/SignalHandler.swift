//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CScoutHang
import Foundation

// A fatal signal can arrive while the crashing thread holds the malloc,
// dyld, or Objective-C runtime lock — anything the handler touches beyond
// async-signal-safe calls can deadlock the process instead of letting it
// die. So everything the handler needs is prepared here, in a safe context:
// the report path, the identity and image-table trailer, and the frame
// buffer all live in plain malloc'd memory the handler only reads. The
// handler itself walks the frame-pointer chain and calls open/write/close —
// nothing else.
private nonisolated(unsafe) var isInstalled = false
private nonisolated(unsafe) var reportPath: UnsafeMutablePointer<CChar>?
private nonisolated(unsafe) var reportTrailer: UnsafeMutableRawPointer?
private nonisolated(unsafe) var reportTrailerCount = 0
private nonisolated(unsafe) var reportFrames: UnsafeMutablePointer<UInt64>?
private nonisolated(unsafe) var reportSession: Protected<UUID>?

private let fatalSignals: [(signal: Int32, name: String)] = [
    (SIGABRT, "SIGABRT"),
    (SIGSEGV, "SIGSEGV"),
    (SIGBUS, "SIGBUS"),
    (SIGFPE, "SIGFPE"),
    (SIGILL, "SIGILL"),
    (SIGTRAP, "SIGTRAP"),
]

func installSignalHandler(identity: Identity) {
    guard !isInstalled else { return }
    isInstalled = true

    prepareRawReport(identity: identity)

    let signals = fatalSignals.map(\.signal)
    signals.withUnsafeBufferPointer { buffer in
        _ = scout_crash_install(buffer.baseAddress!, Int32(buffer.count), handleFatalSignal)
    }
}

private func prepareRawReport(identity: Identity) {
    let directory = IncidentArchive.crash.directory
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

    let fileName = "\(UUID().uuidString).\(RawCrashFormat.pathExtension)"
    reportPath = strdup(directory.appendingPathComponent(fileName).path)

    let trailer = RawCrashFormat.trailer(
        identity: identity,
        appVersion: Bundle.main.marketingVersion,
        images: RawCrashReport.Image.loaded()
    )
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: trailer.count, alignment: 1)
    trailer.withUnsafeBytes { pointer.copyMemory(from: $0.baseAddress!, byteCount: $0.count) }
    reportTrailer = pointer
    reportTrailerCount = trailer.count

    reportFrames = .allocate(capacity: StackWalker.maximumFrameCount)
    reportSession = identity.session
}

private func handleFatalSignal(
    _ sig: Int32, _ info: UnsafeMutablePointer<siginfo_t>?, _ context: UnsafeMutableRawPointer?
) {
    writeRawReport(signal: sig, context: context)

    scout_crash_restore(sig)
    raise(sig)
}

private func writeRawReport(signal: Int32, context: UnsafeMutableRawPointer?) {
    guard scout_crash_claim(), let path = reportPath, let trailer = reportTrailer, let frames = reportFrames else {
        return
    }

    var pc: UInt64 = 0
    var fp: UInt64 = 0
    scout_crash_registers(context, &pc, &fp)

    let buffer = UnsafeMutableBufferPointer(start: frames, count: StackWalker.maximumFrameCount)
    let count = StackWalker.walk(pc: pc, fp: fp, into: buffer)

    let fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
    guard fd >= 0 else {
        return
    }

    let session = reportSession?.raw.uuid ?? (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    RawCrashFormat.write(
        fd: fd,
        signal: signal,
        time: Int64(time(nil)),
        session: session,
        frames: UnsafeBufferPointer(start: frames, count: count),
        trailer: UnsafeRawBufferPointer(start: trailer, count: reportTrailerCount)
    )
    close(fd)
}

func signalName(_ sig: Int32) -> String {
    fatalSignals.first { $0.signal == sig }?.name ?? "SIGNAL_\(sig)"
}
