//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct HomeAlertSection: View {
    @ObservedObject var alerts: AlertProvider

    @Binding var path: [HomeDestination]

    @Environment(\.database) private var database
    @State private var isEditorPresented = false

    var body: some View {
        Header(title: "Alerts") {
            HStack(spacing: 8) {
                if let statuses = try? alerts.result?.get() {
                    if statuses.firingCount > 0 {
                        CountBadge(count: statuses.firingCount)
                    }

                    if statuses.count > 0 {
                        AllButton { path.append(.alerts) }
                    }
                } else {
                    AllButton { path.append(.alerts) }
                }
            }
        }
        .padding(.top, -16)
        .sheet(isPresented: $isEditorPresented) {
            Task { await alerts.fetchAgain(in: database) }
        } content: {
            NavigationStack {
                AlertEditorView(provider: alerts)
            }
        }

        switch alerts.result {
        case .success(let statuses) where statuses.allHealthy:
            placeholderText("All healthy", color: .green)

        case .success(let statuses) where statuses.count > 0:
            ForEach(statuses.prefix(2), id: \.rule) { status in
                AlertRow(status: status)
            }

        case .success:
            Button {
                isEditorPresented = true
            } label: {
                placeholderText("New rule", color: .blue)
            }
            .buttonStyle(.plain)

        default:
            ForEach(0..<2, id: \.self) { _ in
                AlertRowPlaceholder()
            }
        }
    }

    private func placeholderText(_ text: String, color: Color) -> some View {
        Text(verbatim: text)
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(color.opacity(0.7))
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
    }
}

extension HomeAlertSection {
    init(statuses: [AlertStatus]) {
        self.init(alerts: .init(.success(statuses)), path: .constant([]))
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeAlertSection(statuses: [.firingSample, .armedSample])
            HomeAlertSection(statuses: [.armedSample])
            HomeAlertSection(statuses: [])
        }
    }
}
