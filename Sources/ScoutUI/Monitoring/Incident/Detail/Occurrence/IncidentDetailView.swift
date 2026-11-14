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
        ScrollView {
            if backtrace.result == nil {
                IncidentDetailPlaceholder(element: element, group: group)
                    .transition(.opacity)
            } else {
                detail
                    .transition(.opacity)
            }
        }
        .scrollIndicators(.hidden)
        .animation(.easeOut(duration: 0.2), value: backtrace.result == nil)
        .navigationTint(Element.kind.color)
        .toolbarBackground(Element.kind.detailBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: element.name)
        .tint(Color.textPrimary)
        .task {
            await backtrace.fetchIfNeeded(in: database)
        }
        .task {
            await context.fetchIfNeeded(in: database)
        }
    }

    private var detail: some View {
        let stack = IncidentStack(detail: backtrace.detail, fallback: element.stackTrace)
        return VStack(spacing: 0) {
            summary(stack: stack)
            IncidentDetailHeader(title: "Context")
            IncidentContextRows(element: element, group: group, context: contextValue, isLoading: context.result == nil)
            IncidentDetailHeader(title: "Stack Trace", caption: "\(element.detailThread) · \(stack.isSymbolicated ? "symbolicated" : "unsymbolicated")")
            IncidentStackView(stack: stack, color: Element.kind.detailColor)
        }
        .padding(.horizontal, .gutter)
    }

    private var contextValue: IncidentContext? {
        guard case .success(let value) = context.result else {
            return nil
        }
        return value
    }

    private func summary(stack: IncidentStack) -> some View {
        VStack(alignment: .leading, spacing: .space6) {
            if let reason = element.reason {
                Text(verbatim: reason)
                    .font(.scoutRowMono)
                    .foregroundStyle(Element.kind.detailColor)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let meta = metaText(version: contextValue?.appVersion) {
                meta
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }

            if let culprit = stack.culprit {
                IncidentCulpritCard(element: element, culprit: culprit, caller: stack.caller)
                    .padding(.top, .space4)
            }
        }
        .padding(.top, .space18)
        .padding(.bottom, .space16)
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
            parts.append(Text(verbatim: accent).foregroundColor(Element.kind.detailColor).font(.scoutCaptionStrong))
        }
        if let source = meta.source {
            parts.append(Text(verbatim: source))
        }
        if let version {
            parts.append(Text(verbatim: version).font(.scoutValue))
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
        HStack(spacing: .space8) {
            Text(verbatim: title.uppercased())
                .font(.scoutSection)

            Spacer()

            trailing()
        }
        .padding(.top, .space12)
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
                .font(.scoutCaption)
                .foregroundColor(Color.textMuted)
        }
    }
}

private struct IncidentCulpritCard<Element: Incident & IncidentDetailInfo>: View {
    let element: Element
    let culprit: IncidentStackRow
    let caller: IncidentStackRow?

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: element.detailCulprit)
                .font(.scoutFootnote)
                .foregroundStyle(Color.textMuted)

            if let symbol = culprit.symbol {
                Text(verbatim: symbol)
                    .font(.scoutNavEvent)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let location = culprit.location {
                Text(verbatim: location.text)
                    .font(.scoutCode)
                    .foregroundStyle(Element.kind.detailColor)
            }

            if let caller, let callerSymbol = caller.bareSymbol, let callerLocation = caller.location {
                (Text(verbatim: "called from ")
                    + Text(verbatim: callerSymbol).font(.scoutCode).foregroundColor(Color.textPrimary)
                    + Text(verbatim: " · line \(callerLocation.line)"))
                    .font(.scoutFootnote)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .space12)
        .padding(.vertical, .space12)
        .background {
            RoundedRectangle(cornerRadius: .radiusBlock)
                .fill(Color.surfaceGrey)
        }
    }
}
