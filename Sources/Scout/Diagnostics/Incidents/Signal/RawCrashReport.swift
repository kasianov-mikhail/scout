//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

// A fatal-signal report as the handler leaves it on disk: raw return
// addresses plus the image table snapshotted at install, everything else
// pre-rendered before the signal ever fires. The next launch turns it into
// a regular CrashInfo by rebasing each address against the same image
// loaded in the current process and symbolicating there — dladdr can never
// run inside a signal handler.
struct RawCrashReport {
    let signal: Int32
    let date: Date
    let sessionID: UUID
    let addresses: [UInt64]
    let installID: UUID
    let launchID: UUID
    let deviceID: UUID
    let appVersion: String?
    let images: [LoadedImage]

    init?(data: Data) {
        var reader = ByteReader(data: data)

        guard reader.read(UInt32.self) == RawCrashFormat.magic else {
            return nil
        }
        guard let version = reader.read(UInt32.self), RawCrashFormat.readableVersions.contains(version) else {
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
        guard let installID = reader.readUUID(), let launchID = reader.readUUID(), let deviceID = reader.readUUID() else {
            return nil
        }
        guard let appVersion = reader.readString() else {
            return nil
        }
        guard let images = reader.readImages(hasUUID: version >= 2) else {
            return nil
        }

        self.signal = signal
        self.date = Date(timeIntervalSince1970: TimeInterval(time))
        self.sessionID = sessionID
        self.addresses = addresses
        self.installID = installID
        self.launchID = launchID
        self.deviceID = deviceID
        self.appVersion = appVersion.isEmpty ? nil : appVersion
        self.images = images
    }

    var crashInfo: CrashInfo {
        CrashInfo(
            name: signalName(signal),
            reason: signalReason(signal: signal),
            stackTrace: symbolicatedStackTrace,
            backtrace: Backtrace(addresses: addresses, images: images),
            date: date,
            installID: installID,
            launchID: launchID,
            sessionID: sessionID,
            appVersion: appVersion
        )
    }

    private var symbolicatedStackTrace: [String] {
        let loaded = LoadedImage.loadedByName()

        return addresses.enumerated().map { index, address in
            guard let image = images.first(where: { $0.contains(address: address) }) else {
                return StackWalker.unknownFrame(
                    index: index,
                    address: address
                )
            }

            let offset = address - image.base
            if let current = loaded[image.name], current.uuid == image.uuid {
                return StackWalker.symbolicate(
                    index: index,
                    address: current.base + offset
                )
            }
            return StackWalker.offsetFrame(
                index: index,
                image: image.name,
                offset: "0x\(String(offset, radix: 16))"
            )
        }
    }
}

extension LoadedImage {
    fileprivate static func loadedByName() -> [String: LoadedImage] {
        Dictionary(loaded().map { ($0.name, $0) }, uniquingKeysWith: { first, _ in first })
    }
}
