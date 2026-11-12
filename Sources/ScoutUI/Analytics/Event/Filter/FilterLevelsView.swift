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
            VStack(alignment: .leading, spacing: .space4) {
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
                                        showsDivider: levelIndex < levels.count - 1,
                                        alignment: .center
                                    ) {
                                        draft.toggle(levels[levelIndex])
                                    }
                                }
                            }
                            .overlay(alignment: .bottom) {
                                if index < Self.rows.count - 1 {
                                    Rectangle()
                                        .fill(Color.lineSeparator)
                                        .frame(height: 0.5)
                                }
                            }
                        }
                    }
                }

                Text(verbatim: "Pick none to see every level.")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
        }
    }
}

private let warningInk = Color.textCaution
private let warningFill = Color.tintCaution
private let errorInk = Color.textWarning
private let errorFill = Color.tintWarning
private let criticalInk = Color.textDanger
private let criticalFill = Color.tintDanger

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
            .textPrimary
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
            .surfaceGrey
        }
    }
}

#Preview {
    FilterLevelsView(draft: FilterDraft(query: .constant(EventQuery(levels: [.error]))))
        .padding(.space16)
}
