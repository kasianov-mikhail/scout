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
        let images = (0..<_dyld_image_count()).compactMap { index -> LoadedImage? in
            guard let name = _dyld_get_image_name(index), let header = _dyld_get_image_header(index) else {
                return nil
            }
            return LoadedImage(path: name, header: header)
        }
        guard let infos = dyld_all_image_infos(task: mach_task_self_), let linker = LoadedImage(linker: infos) else {
            return images
        }
        return images + [linker]
    }
}

extension LoadedImage {
    fileprivate init(path: UnsafePointer<CChar>, header: UnsafePointer<mach_header>) {
        let path = String(cString: path)
        self.init(
            name: path.components(separatedBy: "/").last ?? path,
            base: UInt64(UInt(bitPattern: header)),
            size: scout_image_text_size(header),
            uuid: UUID(header: header)
        )
    }

    fileprivate init?(linker: dyld_all_image_infos) {
        guard let path = linker.dyldPath, let header = linker.dyldImageLoadAddress else {
            return nil
        }
        self.init(path: path, header: header)
    }
}

extension dyld_all_image_infos {
    fileprivate init?(task: task_t) {
        var info = task_dyld_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_dyld_info>.size / MemoryLayout<natural_t>.size)

        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(task, task_flavor_t(TASK_DYLD_INFO), rebound, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }
        guard let infos = UnsafePointer<dyld_all_image_infos>(bitPattern: UInt(info.all_image_info_addr)) else {
            return nil
        }
        self = infos.pointee
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
