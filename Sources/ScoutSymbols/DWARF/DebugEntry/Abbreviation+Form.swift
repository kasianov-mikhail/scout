//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension Abbreviation {
    enum Form: UInt64 {
        case address = 0x01
        case block2 = 0x03
        case block4 = 0x04
        case data2 = 0x05
        case data4 = 0x06
        case data8 = 0x07
        case string = 0x08
        case block = 0x09
        case block1 = 0x0A
        case data1 = 0x0B
        case flag = 0x0C
        case sdata = 0x0D
        case strp = 0x0E
        case udata = 0x0F
        case refAddress = 0x10
        case ref1 = 0x11
        case ref2 = 0x12
        case ref4 = 0x13
        case ref8 = 0x14
        case refUData = 0x15
        case indirect = 0x16
        case sectionOffset = 0x17
        case exprloc = 0x18
        case flagPresent = 0x19
        case strx = 0x1A
        case addrx = 0x1B
        case refSup4 = 0x1C
        case strpSup = 0x1D
        case data16 = 0x1E
        case lineStrp = 0x1F
        case refSig8 = 0x20
        case implicitConst = 0x21
        case loclistx = 0x22
        case rnglistx = 0x23
        case refSup8 = 0x24
        case strx1 = 0x25
        case strx2 = 0x26
        case strx3 = 0x27
        case strx4 = 0x28
        case addrx1 = 0x29
        case addrx2 = 0x2A
        case addrx3 = 0x2B
        case addrx4 = 0x2C

        var fixedSize: Int? {
            switch self {
            case .data1, .ref1, .flag, .strx1, .addrx1: 1
            case .data2, .ref2, .strx2, .addrx2: 2
            case .strx3, .addrx3: 3
            case .data4, .ref4, .refSup4, .strx4, .addrx4: 4
            case .data8, .ref8, .refSig8, .refSup8: 8
            case .data16: 16
            case .flagPresent, .implicitConst: 0
            default: nil
            }
        }
    }
}
