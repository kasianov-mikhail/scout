//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package enum Condition: String, CaseIterable, Sendable {
    case memoryWarning = "memory_warning"
    case memoryCritical = "memory_critical"
    case thermalNominal = "thermal_nominal"
    case thermalFair = "thermal_fair"
    case thermalSerious = "thermal_serious"
    case thermalCritical = "thermal_critical"
    case lowPowerOn = "low_power_on"
    case lowPowerOff = "low_power_off"

    enum Group {
        case memory, thermal, power
    }

    init(thermalState: ProcessInfo.ThermalState) {
        switch thermalState {
        case .nominal:
            self = .thermalNominal
        case .fair:
            self = .thermalFair
        case .serious:
            self = .thermalSerious
        case .critical:
            self = .thermalCritical
        @unknown default:
            self = .thermalNominal
        }
    }

    init(lowPowerMode: Bool) {
        self = lowPowerMode ? .lowPowerOn : .lowPowerOff
    }

    var group: Group {
        switch self {
        case .memoryWarning, .memoryCritical:
            .memory
        case .thermalNominal, .thermalFair, .thermalSerious, .thermalCritical:
            .thermal
        case .lowPowerOn, .lowPowerOff:
            .power
        }
    }

    var isDefault: Bool {
        self == .thermalNominal || self == .lowPowerOff
    }
}
