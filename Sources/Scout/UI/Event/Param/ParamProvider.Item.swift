//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ParamProvider {
    struct Item: Identifiable, Comparable, Hashable, CustomStringConvertible {
        let id = UUID()
        let key: String
        let value: String

        static func fromData(_ data: Data) throws -> [Item] {
            try JSONDecoder().decode([String: String].self, from: data).map(Item.init)
        }

        static func < (lhs: Item, rhs: Item) -> Bool {
            lhs.key < rhs.key
        }

        var description: String {
            "\(key): \(value)"
        }
    }
}

extension ParamProvider.Item {
    /// An in-app purchase where every value is a typed scalar.
    static var samplePurchase: [ParamProvider.Item] {
        [
            ParamProvider.Item(key: "product_id", value: "com.scout.pro.yearly"),
            ParamProvider.Item(key: "price", value: "49.99"),
            ParamProvider.Item(key: "currency", value: "USD"),
            ParamProvider.Item(key: "introductory", value: "true"),
            ParamProvider.Item(key: "transaction_id", value: "1B2F4A89-0C3D-4E5F-A6B7-C8D9E0F1A2B3"),
            ParamProvider.Item(key: "receipt_url", value: "https://buy.itunes.apple.com/verifyReceipt"),
            ParamProvider.Item(key: "purchased_at", value: "2026-06-11T09:41:00Z"),
        ]
    }

    /// An experiment assignment with plain and structured array values.
    static var sampleExperiments: [ParamProvider.Item] {
        [
            ParamProvider.Item(key: "cohort", value: "B"),
            ParamProvider.Item(key: "enrolled", value: "true"),
            ParamProvider.Item(key: "updated_at", value: "2026-06-09T18:25:43.511Z"),
            ParamProvider.Item(key: "variants", value: #"["chart_v2", "onboarding_short", "paywall_soft"]"#),
            ParamProvider.Item(key: "weights", value: "[0.5, 0.3, 0.2]"),
            ParamProvider.Item(
                key: "assignments",
                value: """
                    [
                      {"name": "chart_v2", "active": true, "since": "2026-05-02T10:00:00Z"},
                      {"name": "onboarding_short", "active": true, "since": "2026-05-20T08:30:00Z"},
                      {"name": "paywall_soft", "active": false, "since": "2026-04-11T12:00:00Z"}
                    ]
                    """
            ),
        ]
    }

    /// A user profile with deeply nested preferences.
    static var sampleProfile: [ParamProvider.Item] {
        [
            ParamProvider.Item(key: "user_id", value: "C0FFEE00-1234-4ABC-9DEF-567890ABCDEF"),
            ParamProvider.Item(key: "plan", value: "premium"),
            ParamProvider.Item(key: "age", value: "34"),
            ParamProvider.Item(key: "verified", value: "true"),
            ParamProvider.Item(key: "signup_date", value: "2024-11-03T14:00:00Z"),
            ParamProvider.Item(
                key: "preferences",
                value: """
                    {
                      "appearance": {
                        "theme": "dark",
                        "text_size": 1.15,
                        "reduce_motion": false
                      },
                      "notifications": {
                        "push": true,
                        "email": false,
                        "quiet_hours": ["22:00", "08:00"]
                      }
                    }
                    """
            ),
        ]
    }

    /// A crash report with a long multi-line stack trace string.
    static var sampleCrash: [ParamProvider.Item] {
        [
            ParamProvider.Item(key: "signal", value: "SIGSEGV"),
            ParamProvider.Item(key: "thread", value: "12"),
            ParamProvider.Item(key: "uptime_s", value: "3724.6"),
            ParamProvider.Item(
                key: "memory",
                value: #"{"footprint_mb": 412.7, "peak_mb": 523.1, "pressure": "warning"}"#
            ),
            ParamProvider.Item(
                key: "stack_trace",
                value: """
                    0  Scout      0x0000000102e4f8a4 ChartModel.rebuild() + 132
                    1  Scout      0x0000000102e4d210 ChartView.body.getter + 88
                    2  SwiftUI    0x00000001c2a91e40 ViewGraph.update() + 1056
                    3  SwiftUI    0x00000001c2a8f6b0 ViewRendererHost.render() + 384
                    4  UIKitCore  0x00000001b8e2d4c8 _UIUpdateSequenceRun + 84
                    5  UIKitCore  0x00000001b8e2cf08 schedulerStepScheduledMainSection + 144
                    6  CoreFoundation 0x00000001a6b3e9ac __CFRunLoopRun + 1996
                    7  Scout      0x0000000102e21034 main + 64
                    """
            ),
        ]
    }

    /// A performance metric with numeric samples and a histogram.
    static var sampleMetrics: [ParamProvider.Item] {
        [
            ParamProvider.Item(key: "name", value: "chart_render"),
            ParamProvider.Item(key: "unit", value: "ms"),
            ParamProvider.Item(key: "count", value: "240"),
            ParamProvider.Item(key: "p50", value: "16.7"),
            ParamProvider.Item(key: "p95", value: "182.4"),
            ParamProvider.Item(key: "collected_at", value: "2026-06-11T07:00:00Z"),
            ParamProvider.Item(key: "samples", value: "[12.1, 14.9, 16.7, 21.3, 48.2, 182.4]"),
            ParamProvider.Item(key: "histogram", value: #"{"0_50": 218, "50_100": 14, "100_250": 8}"#),
        ]
    }
}
