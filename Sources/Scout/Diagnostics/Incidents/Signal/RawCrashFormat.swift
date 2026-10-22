//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

enum RawCrashFormat {
    static let magic: UInt32 = 0x5752_4353
    static let version: UInt32 = 2
    static let readableVersions: ClosedRange<UInt32> = 1...2
    static let pathExtension = "rawcrash"
    static let missingUUID = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

    static func trailer(identity: Identity, appVersion: String?, images: [LoadedImage]) -> [UInt8] {
        var bytes: [UInt8] = []

        append(identity.install.uuid, to: &bytes)
        append(identity.launch.uuid, to: &bytes)
        append(identity.device.uuid, to: &bytes)

        let version = Array((appVersion ?? "").utf8)
        append(UInt32(version.count), to: &bytes)
        bytes += version

        append(UInt32(images.count), to: &bytes)
        for image in images {
            append(image.base, to: &bytes)
            append(image.size, to: &bytes)
            append((image.uuid ?? missingUUID).uuid, to: &bytes)

            let name = Array(image.name.utf8)
            append(UInt32(name.count), to: &bytes)
            bytes += name
        }

        return bytes
    }

    static func writeFromSignalHandler(fd: Int32, signal: Int32, time: Int64, session: uuid_t, frames: UnsafeBufferPointer<UInt64>, trailer: UnsafeRawBufferPointer) {
        writeValue(magic, to: fd)
        writeValue(version, to: fd)
        writeValue(signal, to: fd)
        writeValue(time, to: fd)
        writeValue(session, to: fd)
        writeValue(UInt32(frames.count), to: fd)
        _ = Darwin.write(fd, frames.baseAddress, frames.count * MemoryLayout<UInt64>.size)
        _ = Darwin.write(fd, trailer.baseAddress, trailer.count)
    }

    private static func append<T>(_ value: T, to bytes: inout [UInt8]) {
        withUnsafeBytes(of: value) { bytes += $0 }
    }

    private static func writeValue<T>(_ value: T, to fd: Int32) {
        withUnsafeBytes(of: value) { _ = Darwin.write(fd, $0.baseAddress, $0.count) }
    }
}
