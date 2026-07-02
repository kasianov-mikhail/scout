//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct FunnelStep: Identifiable {
    let name: String
    let count: Int

    var id: String { name }
}

struct FunnelStepMetrics: Identifiable {
    let step: FunnelStep
    let index: Int
    let fractionOfFirst: Double
    let conversionFromPrevious: Double?
    let dropOff: Int

    var id: String { step.id }
}

extension Array where Element == FunnelStep {
    var metrics: [FunnelStepMetrics] {
        guard let first = self.first, first.count > 0 else { return [] }
        var previous: FunnelStep?
        return enumerated().map { index, step in
            let conversion = previous.map { $0.count > 0 ? Double(step.count) / Double($0.count) : 0 }
            let dropOff = previous.map { $0.count - step.count } ?? 0
            previous = step
            return FunnelStepMetrics(
                step: step,
                index: index,
                fractionOfFirst: Double(step.count) / Double(first.count),
                conversionFromPrevious: conversion,
                dropOff: dropOff
            )
        }
    }
}

extension Double {
    var funnelPercent: String {
        formatted(.percent.precision(.fractionLength(0)))
    }
}

extension FunnelStep {
    static let samples: [FunnelStep] = [
        FunnelStep(name: "app_open", count: 12480),
        FunnelStep(name: "signup_started", count: 7713),
        FunnelStep(name: "signup_completed", count: 4767),
        FunnelStep(name: "first_sync", count: 2946),
        FunnelStep(name: "purchase", count: 1821),
    ]
}
