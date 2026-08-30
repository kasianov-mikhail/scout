//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CScoutHang
import Foundation
import MachO

// A fatal-signal report as the handler leaves it on disk: raw return
// addresses plus the image table snapshotted at install, everything else
// pre-rendered before the signal ever fires. The next launch turns it into
// a regular CrashInfo by rebasing each address against the same image
// loaded in the current process and symbolicating there — dladdr can never
// run inside a signal handler.
struct RawCrashReport {
    struct Image {
        let name: String
        let base: UInt64
        let size: UInt64
    }

    let signal: Int32
    let date: Date
    let sessionID: UUID
    let addresses: [UInt64]
    let installID: UUID
    let launchID: UUID
    let deviceID: UUID
    let appVersion: String?
    let images: [Image]

    init?(data: Data) {
        var reader = ByteReader(data: data)

        guard reader.read(UInt32.self) == RawCrashFormat.magic else {
            return nil
        }
        guard reader.read(UInt32.self) == RawCrashFormat.version else {
            return nil
        }
        guard let signal = reader.read(Int32.self), let time = reader.read(Int64.self) else {
            return nil
        }
        guard let sessionID = reader.readUUID() else {
            return nil
        }
        guard let addresses = reader.readAddresses(limit: StackWalker.maximumFrameCount) else {
            return nil
        }
        guard let installID = reader.readUUID(), let launchID = reader.readUUID(), let deviceID = reader.readUUID()
        else {
            return nil
        }
        guard let appVersion = reader.readString() else {
            return nil
        }
        guard let images = reader.readImages() else {
            return nil
        }

        self.signal = signal
        self.date = Date(timeIntervalSince1970: TimeInterval(time))
        self.sessionID = sessionID
        self.addresses = addresses
        self.installID = installID
        self.launchID = launchID
        self.deviceID = deviceID
        self.appVersion = appVersion.count > 0 ? appVersion : nil
        self.images = images
    }

    func crashInfo() -> CrashInfo {
        CrashInfo(
            name: signalName(signal),
            reason: "Signal \(signal) received",
            stackTrace: symbolicatedStackTrace(),
            date: date,
            installID: installID,
            launchID: launchID,
            sessionID: sessionID,
            appVersion: appVersion
        )
    }

    private func symbolicatedStackTrace() -> [String] {
        let loaded = Image.loadedBases()

        return addresses.enumerated().map { index, address in
            guard let image = images.first(where: { address >= $0.base && address < $0.base + $0.size })
            else {
                return StackWalker.unknownFrame(index: index, address: address)
            }

            let offset = address - image.base
            if let base = loaded[image.name] {
                return StackWalker.symbolicate(index: index, address: base + offset)
            }
            return "\(index)   \(image.name)   + 0x\(String(offset, radix: 16))"
        }
    }
}

extension RawCrashReport.Image {
    // The __TEXT segment is where every return address lives, so its size is
    // all the report needs to attribute an address to an image.
    static func loaded() -> [RawCrashReport.Image] {
        (0..<_dyld_image_count()).compactMap { index -> RawCrashReport.Image? in
            guard let name = _dyld_get_image_name(index), let header = _dyld_get_image_header(index) else {
                return nil
            }

            let path = String(cString: name)
            return RawCrashReport.Image(
                name: path.components(separatedBy: "/").last ?? path,
                base: UInt64(UInt(bitPattern: header)),
                size: scout_image_text_size(header)
            )
        }
    }

    fileprivate static func loadedBases() -> [String: UInt64] {
        var bases: [String: UInt64] = [:]
        for image in loaded() where bases[image.name] == nil {
            bases[image.name] = image.base
        }
        return bases
    }
}

enum RawCrashFormat {
    static let magic: UInt32 = 0x5752_4353
    static let version: UInt32 = 1
    static let pathExtension = "rawcrash"

    static func trailer(identity: Identity, appVersion: String?, images: [RawCrashReport.Image]) -> [UInt8] {
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

            let name = Array(image.name.utf8)
            append(UInt32(name.count), to: &bytes)
            bytes += name
        }

        return bytes
    }

    // Runs inside the signal handler: nothing here may allocate or lock,
    // only plain memory reads and write(2).
    static func write(fd: Int32, signal: Int32, time: Int64, session: uuid_t, frames: UnsafeBufferPointer<UInt64>, trailer: UnsafeRawBufferPointer) {
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

private struct ByteReader {
    let data: Data
    var offset = 0

    mutating func read<T>(_ type: T.Type) -> T? {
        let size = MemoryLayout<T>.size

        guard offset + size <= data.count else {
            return nil
        }
        defer { offset += size }

        return data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: type) }
    }

    mutating func readUUID() -> UUID? {
        read(uuid_t.self).map { UUID(uuid: $0) }
    }

    mutating func readString() -> String? {
        guard let count = read(UInt32.self), let bytes = readBytes(Int(count)) else {
            return nil
        }
        return String(decoding: bytes, as: UTF8.self)
    }

    mutating func readAddresses(limit: Int) -> [UInt64]? {
        guard let count = read(UInt32.self), count <= UInt32(limit) else {
            return nil
        }

        var addresses: [UInt64] = []
        for _ in 0..<count {
            guard let address = read(UInt64.self) else {
                return nil
            }
            addresses.append(address)
        }
        return addresses
    }

    mutating func readImages() -> [RawCrashReport.Image]? {
        guard let count = read(UInt32.self), count <= 4096 else {
            return nil
        }

        var images: [RawCrashReport.Image] = []
        for _ in 0..<count {
            guard let base = read(UInt64.self), let size = read(UInt64.self), let name = readString() else {
                return nil
            }
            images.append(RawCrashReport.Image(name: name, base: base, size: size))
        }
        return images
    }

    private mutating func readBytes(_ count: Int) -> [UInt8]? {
        guard count >= 0, offset + count <= data.count else {
            return nil
        }
        defer { offset += count }

        return [UInt8](data[data.startIndex + offset..<data.startIndex + offset + count])
    }
}
