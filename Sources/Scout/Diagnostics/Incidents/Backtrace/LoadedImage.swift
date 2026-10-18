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

struct LoadedImage: Equatable {
    let name: String
    let base: UInt64
    let size: UInt64
    let uuid: UUID?

    func contains(address: UInt64) -> Bool {
        address >= base && address < base + size
    }

    static func loaded() -> [LoadedImage] {
        (0..<_dyld_image_count()).compactMap { index -> LoadedImage? in
            guard let name = _dyld_get_image_name(index), let header = _dyld_get_image_header(index) else {
                return nil
            }

            let path = String(cString: name)
            return LoadedImage(
                name: path.components(separatedBy: "/").last ?? path,
                base: UInt64(UInt(bitPattern: header)),
                size: scout_image_text_size(header),
                uuid: UUID(header: header)
            )
        }
    }
}

extension UUID {
    fileprivate init?(header: UnsafePointer<mach_header>) {
        var bytes: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let found = withUnsafeMutableBytes(of: &bytes) { buffer in
            scout_image_uuid(header, buffer.baseAddress!.assumingMemoryBound(to: UInt8.self))
        }
        guard found else {
            return nil
        }
        self.init(uuid: bytes)
    }
}
