//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

struct ByteReader {
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

    mutating func readImages(hasUUID: Bool) -> [LoadedImage]? {
        guard let count = read(UInt32.self), count <= 4096 else {
            return nil
        }

        var images: [LoadedImage] = []
        for _ in 0..<count {
            guard let base = read(UInt64.self), let size = read(UInt64.self) else {
                return nil
            }
            var uuid: UUID?
            if hasUUID {
                guard let stored = readUUID() else {
                    return nil
                }
                uuid = stored == RawCrashFormat.missingUUID ? nil : stored
            }
            guard let name = readString() else {
                return nil
            }
            images.append(LoadedImage(name: name, base: base, size: size, uuid: uuid))
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
