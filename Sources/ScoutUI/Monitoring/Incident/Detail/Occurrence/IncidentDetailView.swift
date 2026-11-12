//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct IncidentDetailView<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let group: IncidentGroup<Element>?

    @StateObject private var backtrace: BacktraceProvider
    @StateObject private var context: IncidentContextProvider
    @Environment(\.database) private var database

    init(element: Element, group: IncidentGroup<Element>? = nil, backtrace: BacktraceProvider? = nil, context: IncidentContextProvider? = nil) {
        self.element = element
        self.group = group
        self._backtrace = StateObject(wrappedValue: backtrace ?? BacktraceProvider(incidentID: element.id))
        self._context = StateObject(wrappedValue: context ?? IncidentContextProvider(sessionID: element.sessionID, deviceID: element.deviceID))
    }

    var body: some View {
        Group {
            if backtrace.result == nil {
                IncidentDetailPlaceholder(element: element, group: group)
                    .transition(.opacity)
            } else {
                detail
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: backtrace.result == nil)
        .navigationTint(Element.kind.color)
        .toolbarBackground(Element.kind.detailBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: element.name)
        .tint(.primary)
        .task {
            await backtrace.fetchIfNeeded(in: database)
        }
        .task {
            await context.fetchIfNeeded(in: database)
        }
    }

    private var detail: some View {
        let stack = IncidentStack(detail: backtrace.detail, fallback: element.stackTrace)
        return ScrollView {
            VStack(spacing: 0) {
                summary(stack: stack)
                IncidentDetailHeader(title: "Context")
                IncidentContextRows(element: element, group: group, context: contextValue, isLoading: context.result == nil)
                IncidentDetailHeader(title: "Stack Trace", caption: "\(element.detailThread) · \(stack.isSymbolicated ? "symbolicated" : "unsymbolicated")")
                IncidentStackView(stack: stack, color: Element.kind.detailColor)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }

    private var contextValue: IncidentContext? {
        guard case .success(let value) = context.result else {
            return nil
        }
        return value
    }

    private func summary(stack: IncidentStack) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let reason = element.reason {
                Text(verbatim: reason)
                    .font(.weight450(size: 15, design: .monospaced))
                    .foregroundStyle(Element.kind.detailColor)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let meta = metaText(version: contextValue?.appVersion) {
                meta
                    .font(.weight450(size: 13))
                    .foregroundStyle(Color(.systemGray))
            }

            if let culprit = stack.culprit {
                IncidentCulpritCard(element: element, culprit: culprit, caller: stack.caller)
                    .padding(.top, 4)
            }
        }
        .padding(.top, 18)
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }

    private func metaText(version: String?) -> Text? {
        let meta = element.detailMeta
        var parts: [Text] = []

        if let date = meta.dateText {
            parts.append(Text(verbatim: date))
        }
        if let accent = meta.accent {
            parts.append(Text(verbatim: accent).foregroundColor(Element.kind.detailColor).font(.system(size: 13, weight: .semibold)))
        }
        if let source = meta.source {
            parts.append(Text(verbatim: source))
        }
        if let version {
            parts.append(Text(verbatim: version).font(.weight450(size: 13, design: .monospaced)))
        }

        guard let first = parts.first else {
            return nil
        }
        var text = first
        for part in parts.dropFirst() {
            text = text + Text(verbatim: " · ") + part
        }
        return text
    }
}

struct IncidentDetailHeader<Trailing: View>: View {
    let title: String

    @ViewBuilder let trailing: () -> Trailing

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 16, weight: .bold))

            Spacer()

            trailing()
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

extension IncidentDetailHeader where Trailing == Text {
    init(title: String, caption: String) {
        self.init(title: title) {
            Text(verbatim: caption)
                .font(.weight450(size: 13))
                .foregroundColor(Color(.systemGray))
        }
    }
}

private struct IncidentCulpritCard<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let culprit: IncidentStackRow
    let caller: IncidentStackRow?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(verbatim: element.detailCulprit)
                .font(.weight450(size: 12))
                .foregroundStyle(Color(.systemGray))

            if let symbol = culprit.symbol {
                Text(verbatim: symbol)
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let location = culprit.location {
                Text(verbatim: location.text)
                    .font(.weight450(size: 12, design: .monospaced))
                    .foregroundStyle(Element.kind.detailColor)
            }

            if let caller, let callerSymbol = caller.bareSymbol, let callerLocation = caller.location {
                (Text(verbatim: "called from ")
                    + Text(verbatim: callerSymbol).font(.weight450(size: 12, design: .monospaced)).foregroundColor(.primary)
                    + Text(verbatim: " · line \(callerLocation.line)"))
                    .font(.weight450(size: 12))
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray6))
        }
    }
}
