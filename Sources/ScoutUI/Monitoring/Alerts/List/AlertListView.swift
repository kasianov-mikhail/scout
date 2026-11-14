//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertListView: View {
    @ObservedObject var provider: AlertProvider

    @Environment(\.database) private var database
    @State private var creation: Creation?
    @State private var selected: AlertStatus?

    private enum Creation: String, Identifiable {
        case composer
        case templates

        var id: String { rawValue }
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.isLoading)
            .navigationTitle(en: "Alerts")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            creation = .composer
                        } label: {
                            Text(verbatim: "New Alert")
                        }

                        Button {
                            creation = .templates
                        } label: {
                            Text(verbatim: "From Template")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $creation) {
                Task { await provider.fetchLatest(in: database) }
            } content: { creation in
                switch creation {
                case .composer:
                    NavigationStack {
                        AlertComposerView(provider: provider)
                    }
                    .opaquePresentation()
                case .templates:
                    AlertTemplateListView(provider: provider)
                        .opaquePresentation()
                }
            }
            .navigationDestination(isPresented: Binding(get: { selected != nil }, set: { if !$0 { selected = nil } })) {
                if let selected {
                    AlertDetailView(provider: provider, rule: selected.rule, status: selected)
                }
            }
            .task {
                await provider.fetchIfNeeded(in: database)
            }
            .notificationStatus(of: provider)
    }

    @ViewBuilder private var content: some View {
        if let error = provider.error {
            ErrorView(description: error.localizedDescription) {
                await provider.fetchAgain(in: database)
            }
        } else if case .success(let statuses) = provider.result, statuses.isEmpty {
            Placeholder(
                text: "No alert rules",
                systemImage: "bell.badge",
                description: "Add a rule to get notified when a metric misbehaves."
            )
        } else {
            ScrollView {
                if case .success(let statuses) = provider.result {
                    list(statuses)
                        .transition(.opacity)
                } else {
                    AlertListPlaceholder()
                        .transition(.opacity)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func list(_ statuses: [AlertStatus]) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if provider.notificationsDenied, statuses.contains(where: \.rule.notifies) {
                NotificationsDeniedRow()
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.separator)
                            .frame(height: 0.5)
                    }
            }

            AlertListLegend()
                .padding(.top, .space10)

            section(statuses.firing, title: "FIRING")
            section(statuses.armed, title: "ARMED")
            section(statuses.muted, title: "MUTED")
        }
        .padding(.horizontal, .gutter)
    }

    @ViewBuilder private func section(_ statuses: [AlertStatus], title: String) -> some View {
        if !statuses.isEmpty {
            AlertListSectionHeader(title: title, count: statuses.count)

            ForEach(Array(statuses.enumerated()), id: \.element.rule) { index, status in
                AlertRuleRow(
                    status: status,
                    isLast: index == statuses.count - 1,
                    onDelete: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            provider.remove(status.rule)
                        }
                    },
                    onMute: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            provider.mute(status.rule, until: Date().addingTimeInterval(3600))
                        }
                    },
                    onOpen: {
                        selected = status
                    }
                )
                .padding(.horizontal, -16)
            }
        }
    }
}

private struct AlertListSectionHeader: View {
    let title: String
    let count: Int

    var body: some View {
        HStack {
            Text(verbatim: title)
                .font(.scoutSection)

            Spacer()

            Text(verbatim: "\(count)")
                .font(.scoutCaption)
                .foregroundStyle(Color.textMuted)
        }
        .padding(.top, .space12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

struct AlertListLegend: View {
    var showsAxis = true

    var body: some View {
        VStack(alignment: .leading, spacing: .space4) {
            HStack {
                Text(verbatim: "24 h ago")
                Spacer()
                Text(verbatim: "12 h")
                Spacer()
                Text(verbatim: "now")
            }
            .font(.scoutAxis)
            .foregroundStyle(Color.textMuted)
            .opacity(showsAxis ? 1 : 0)

            HStack(spacing: .space12) {
                legendItem(color: Color.fillLevel, title: "breached")
                legendItem(color: Color.textDanger, title: "firing now")
            }
            .font(.scoutFootnote)
            .foregroundStyle(Color.textMuted)
        }
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: .space4) {
            RoundedRectangle(cornerRadius: .radiusBar)
                .fill(color)
                .frame(width: 10, height: 10)

            Text(verbatim: title)
        }
    }
}

#Preview("Alerts") {
    NavigationStack {
        AlertListView(provider: .init(.success(AlertStatus.samples)))
    }
}

#Preview("Empty") {
    NavigationStack {
        AlertListView(provider: .init(.success([])))
    }
}

#Preview("Loading") {
    NavigationStack {
        AlertListView(provider: .init())
    }
}
