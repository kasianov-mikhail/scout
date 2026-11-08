//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct FilterLevelsView: View {
    @ObservedObject var draft: FilterDraft

    private static let rows: [[EventLevel]] = [
        [.trace, .debug, .info, .notice],
        [.warning, .error, .critical],
    ]

    var body: some View {
        FilterSection(title: "Levels") {
            VStack(alignment: .leading, spacing: 4) {
                FilterBox {
                    VStack(spacing: 0) {
                        ForEach(Self.rows.indices, id: \.self) { index in
                            let levels = Self.rows[index]

                            HStack(spacing: 0) {
                                ForEach(levels.indices, id: \.self) { levelIndex in
                                    FilterSegment(
                                        title: levels[levelIndex].description,
                                        isSelected: draft.isSelected(levels[levelIndex]),
                                        ink: levels[levelIndex].filterInk,
                                        fill: levels[levelIndex].filterTint,
                                        showsDivider: levelIndex < levels.count - 1
                                    ) {
                                        draft.toggle(levels[levelIndex])
                                    }
                                }
                            }

                            if index < Self.rows.count - 1 {
                                Rectangle()
                                    .fill(Color(.systemGray3))
                                    .frame(height: 0.5)
                            }
                        }
                    }
                }

                Text(verbatim: "Pick none to see every level.")
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }
}

private let warningInk = Color(red: 0x9A / 255, green: 0x72 / 255, blue: 0)
private let warningFill = Color(red: 0x9A / 255, green: 0x72 / 255, blue: 0).opacity(0.14)
private let errorInk = Color(red: 0xB3 / 255, green: 0x5C / 255, blue: 0)
private let errorFill = Color(red: 1, green: 0x95 / 255, blue: 0).opacity(0.14)
private let criticalInk = Color(red: 0xC4 / 255, green: 0, blue: 0x1A / 255)
private let criticalFill = Color(red: 0xC4 / 255, green: 0, blue: 0x1A / 255).opacity(0.14)

extension EventLevel {
    fileprivate var filterInk: Color {
        switch self {
        case .warning:
            warningInk
        case .error:
            errorInk
        case .critical:
            criticalInk
        default:
            .primary
        }
    }

    fileprivate var filterTint: Color {
        switch self {
        case .warning:
            warningFill
        case .error:
            errorFill
        case .critical:
            criticalFill
        default:
            Color(.systemGray6)
        }
    }
}

#Preview {
    FilterLevelsView(draft: FilterDraft(query: .constant(EventQuery(levels: [.error]))))
        .padding(16)
}
