//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Testing

@testable import Scout

struct CriteriaTests {
    enum TestEnum: String, CaseIterable, Hashable {
        case one, two, three
    }

    let criteria = Criteria(selected: .constant(Set<TestEnum>()))

    @Test("Check if item is enabled") func testIsLevelEnabled() {
        #expect(criteria.isSelected(.one) == false)

        criteria.toggle(.one)
        #expect(criteria.isSelected(.one))
    }

    @Test("Check toggle functionality") func testToggle() {
        criteria.toggle(.one)
        #expect(criteria.isSelected(.one))

        criteria.toggle(.one)
        #expect(criteria.isSelected(.one) == false)
    }

    @Test("Check if apply button is disabled when no items are enabled") func testIsApplyEnabled() {
        #expect(criteria.isApplyEnabled == false)

        criteria.toggle(.one)
        #expect(criteria.isApplyEnabled)
    }

    @Test("Check apply functionality") func testApply() {
        criteria.toggle(.one)
        criteria.apply()

        #expect(criteria.isApplyEnabled)
    }

    @Test("Check if reset button is disabled when no items are enabled") func testIsResetEnabled() {
        let criteria = Criteria(selected: .constant(Set(TestEnum.allCases)))

        #expect(criteria.isResetEnabled == false)

        criteria.toggle(.one)
        #expect(criteria.isResetEnabled)
    }

    @Test("Ensure all items are reset correctly") func testReset() {
        criteria.toggle(.one)
        #expect(criteria.isSelected(.one))

        criteria.reset()
        #expect(criteria.isSelected(.one))
        #expect(criteria.isSelected(.two))
        #expect(criteria.isSelected(.three))
    }
}
