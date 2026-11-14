//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutUI

@Suite("HomeTypography")
struct HomeTypographyTests {
    @Test("The experiment ships 20 variants in order")
    func variantsInOrder() {
        #expect(HomeTypography.variants.map(\.id) == (1...20).map { String(format: "V%02d", $0) })
        #expect(HomeTypography.variants.count == 20)
    }

    @Test("V01 is the design as it is")
    func v01MatchesDesign() {
        let variant = HomeTypography.v01

        #expect(variant.regular == 400)
        #expect(variant.strong == 600)
        #expect(variant.bold == 700)
        #expect(variant.muted == 0x8E8E93)
        #expect(variant.secondary == 0x6C6C70)
        #expect(variant.smallIncrement == 0)
        #expect(variant.smallTracking == 0)
    }

    @Test("The variant number follows the variant fields")
    func variantsMatchTheTable() {
        let expected: [(String, CGFloat, CGFloat, CGFloat, UInt32, UInt32, CGFloat, CGFloat)] = [
            ("V02", 450, 600, 700, 0x8E8E93, 0x6C6C70, 0, 0),
            ("V03", 400, 600, 700, 0x7C7C80, 0x6C6C70, 0, 0),
            ("V04", 400, 600, 700, 0x6C6C70, 0x6C6C70, 0, 0),
            ("V05", 400, 600, 700, 0x636366, 0x636366, 0, 0),
            ("V06", 450, 600, 700, 0x7C7C80, 0x6C6C70, 0, 0),
            ("V07", 450, 600, 700, 0x6C6C70, 0x6C6C70, 0, 0),
            ("V08", 450, 600, 700, 0x636366, 0x636366, 0, 0),
            ("V09", 500, 600, 700, 0x8E8E93, 0x6C6C70, 0, 0),
            ("V10", 500, 600, 700, 0x7C7C80, 0x6C6C70, 0, 0),
            ("V11", 500, 600, 700, 0x6C6C70, 0x6C6C70, 0, 0),
            ("V12", 400, 600, 700, 0x8E8E93, 0x6C6C70, 1, 0),
            ("V13", 450, 600, 700, 0x7C7C80, 0x6C6C70, 1, 0),
            ("V14", 450, 600, 700, 0x6C6C70, 0x6C6C70, 1, 0),
            ("V15", 450, 650, 750, 0x6C6C70, 0x6C6C70, 0, 0),
            ("V16", 500, 650, 750, 0x6C6C70, 0x6C6C70, 0, 0),
            ("V17", 450, 600, 700, 0x6C6C70, 0x48484A, 0, 0),
            ("V18", 450, 600, 700, 0x636366, 0x48484A, 1, 0),
            ("V19", 400, 600, 700, 0x8E8E93, 0x6C6C70, 0, 0.2),
            ("V20", 450, 600, 700, 0x6C6C70, 0x6C6C70, 0, 0.2),
        ]

        for (index, row) in expected.enumerated() {
            let variant = HomeTypography.variants[index + 1]

            #expect(variant.id == row.0)
            #expect(variant.regular == row.1)
            #expect(variant.strong == row.2)
            #expect(variant.bold == row.3)
            #expect(variant.muted == row.4)
            #expect(variant.secondary == row.5)
            #expect(variant.smallIncrement == row.6)
            #expect(variant.smallTracking == row.7)
        }
    }

    @Test("A small role grows and tracks only when the variant says so")
    func smallRoles() {
        #expect(HomeTypography.v12.size(.caption) == 14)
        #expect(HomeTypography.v19.size(.caption) == 13)
        #expect(HomeTypography.v19.tracking(.caption) == 0.2)
        #expect(HomeTypography.v12.tracking(.caption) == 0)
        #expect(HomeTypography.v12.size(.monoOff) == 13)
        #expect(HomeTypography.v19.tracking(.monoOff) == 0)
        #expect(HomeTypography.v19.tracking(.row) == 0)
        #expect(HomeTypography.v19.tracking(.stripLabel) == 0.2)
    }

    @Test("The switcher label names every difference from V01")
    func labels() {
        #expect(HomeTypography.v01.label == "V01 · 400 · #8E8E93")
        #expect(HomeTypography.v02.label == "V02 · 450 · #8E8E93")
        #expect(HomeTypography.v07.label == "V07 · 450 · #6C6C70")
        #expect(HomeTypography.v12.label == "V12 · 400 · #8E8E93 · +1")
        #expect(HomeTypography.v15.label == "V15 · 450 · #6C6C70 · 650/750")
        #expect(HomeTypography.v17.label == "V17 · 450 · #6C6C70 · sec #48484A")
        #expect(HomeTypography.v18.label == "V18 · 450 · #636366 · +1 · sec #48484A")
        #expect(HomeTypography.v19.label == "V19 · 400 · #8E8E93 · tr +0.2")
        #expect(HomeTypography.v20.label == "V20 · 450 · #6C6C70 · tr +0.2")
        #expect(Set(HomeTypography.variants.map(\.label)).count == 20)
    }

    @Test("Only TestFlight, Debug and the simulator show the experiment")
    func availability() {
        #expect(HomeTypographyExperiment.isAvailable(receiptName: "sandboxReceipt", isDebug: false, isSimulator: false))
        #expect(!HomeTypographyExperiment.isAvailable(receiptName: "receipt", isDebug: false, isSimulator: false))
        #expect(!HomeTypographyExperiment.isAvailable(receiptName: nil, isDebug: false, isSimulator: false))
        #expect(HomeTypographyExperiment.isAvailable(receiptName: nil, isDebug: true, isSimulator: false))
        #expect(HomeTypographyExperiment.isAvailable(receiptName: nil, isDebug: false, isSimulator: true))
    }

    @Test("The App Store build always renders V01")
    func appStoreUsesV01() {
        #expect(HomeTypographyExperiment.selection(stored: "V07", available: false) == .v01)
        #expect(HomeTypographyExperiment.selection(stored: "V07", available: true) == .v07)
        #expect(HomeTypographyExperiment.selection(stored: "unknown", available: true) == .v01)
    }
}
