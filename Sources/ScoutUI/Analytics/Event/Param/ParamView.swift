//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ParamView: View {
    private let key: String
    private let value: ParamValue
    private let raw: String

    @State private var message: Message?

    /// Shows a fetched parameter, keeping its raw text for sharing.
    init(item: ParamProvider.Item) {
        key = item.key
        value = ParamValue(parsing: item.value)
        raw = item.value
    }

    /// Shows a nested value reached by drilling into a container.
    init(node: ParamValue.Node) {
        key = node.label
        value = node.value
        raw = node.value.text
    }

    var body: some View {
        Group {
            if value.isContainer {
                InsetList {
                    ForEach(value.nodes) { node in
                        Row {
                            ParamValueRow(node: node)
                        } destination: {
                            ParamView(node: node)
                        }
                    }
                }
            } else {
                ParamScalarView(raw: raw, value: value)
            }
        }
        .monospacedNavigationTitle(en: key)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ShareLink(item: raw)
                CopyButton(text: raw, message: $message)
                Spacer()
            }
        }
        .message($message)
        .resetsTint()
    }
}

/// The scalar layout of a parameter value: a kind badge for recognized scalars
/// above the verbatim text.
///
private struct ParamScalarView: View {
    let raw: String
    let value: ParamValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 13) {
                if case .stringConvertible(let convertible) = value {
                    ParamBadge(convertible: convertible)
                }

                Text(raw)
                    .monospaced()
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

#Preview("Dictionary") {
    NavigationStack {
        ParamView(item: ParamProvider.Item.sampleProfile.first { $0.key == "preferences" }!)
    }
    .environmentObject(Tint())
}

#Preview("Array") {
    NavigationStack {
        ParamView(item: ParamProvider.Item.sampleExperiments.first { $0.key == "assignments" }!)
    }
    .environmentObject(Tint())
}

#Preview("Scalar") {
    NavigationStack {
        ParamView(item: ParamProvider.Item.samplePurchase.first { $0.key == "purchased_at" }!)
    }
    .environmentObject(Tint())
}

#Preview("Text") {
    NavigationStack {
        ParamView(item: ParamProvider.Item.sampleCrash.first { $0.key == "stack_trace" }!)
    }
    .environmentObject(Tint())
}
