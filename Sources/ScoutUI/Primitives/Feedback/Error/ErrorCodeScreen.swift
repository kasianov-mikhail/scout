//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ErrorCodeScreen: View {
    let code: String
    var cloud = false
    let title: String
    let message: String
    let endpoint: String
    let retry: () -> Void

    var body: some View {
        ErrorScreen {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 24)

                ErrorCodeArtwork(code: code, cloud: cloud)

                Text(verbatim: title)
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 8)

                Text(verbatim: message)
                    .font(.weight450(size: 17))
                    .lineSpacing(4)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                Text(verbatim: endpoint)
                    .font(.weight450(size: 13, design: .monospaced))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 16)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
        } actions: {
            Button(action: retry) {
                Text(verbatim: "Retry")
            }
            .buttonStyle(ErrorActionButtonStyle(role: .primary))
        }
    }
}

private struct ErrorCodeArtwork: View {
    let code: String
    var cloud = false

    private static let height: CGFloat = 120
    private static let baseline: CGFloat = 110
    private static let step: CGFloat = 12
    private static let codeX: CGFloat = 168
    private static let designWidth: CGFloat = 342

    var body: some View {
        Canvas { context, size in
            var grid = Path()
            for x in stride(from: 0, through: size.width, by: Self.step) {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: Self.height))
            }
            for y in stride(from: 2, through: Self.baseline, by: Self.step) {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(grid, with: .color(Color(.systemGray6)), lineWidth: 1)

            if cloud {
                let left = CGRect(x: 0, y: 42.6, width: 67.4, height: 67.4)
                let middle = CGRect(x: 42.1, y: 14, width: 91, height: 91)
                let right = CGRect(x: 97.7, y: 56.1, width: 53.9, height: 53.9)

                var fill = Path()
                fill.addEllipse(in: left)
                fill.addEllipse(in: middle)
                fill.addEllipse(in: right)
                fill.addRect(CGRect(x: 33.7, y: 76.3, width: 90.9, height: 33.7))
                context.fill(fill, with: .color(Color(.systemGray6)))

                var outline = Path()
                outline.addEllipse(in: left)
                outline.addEllipse(in: middle)
                outline.addEllipse(in: right)
                context.stroke(outline, with: .color(Color(.systemGray4)), lineWidth: 1)
            }

            var baseline = Path()
            baseline.move(to: CGPoint(x: 0, y: Self.baseline))
            baseline.addLine(to: CGPoint(x: size.width, y: Self.baseline))
            context.stroke(baseline, with: .color(Color(.systemGray4)), lineWidth: 1)

            let text = Text(verbatim: code)
                .font(.system(size: 120, weight: .heavy, design: .rounded))
                .tracking(code.count > 1 ? -4 : 0)
                .foregroundColor(Color(.systemGray5))
            let resolved = context.resolve(text)
            let measured = resolved.measure(in: CGSize(width: size.width, height: Self.height))
            let baselineOffset = resolved.firstBaseline(in: measured)
            let x = cloud ? size.width * Self.codeX / Self.designWidth : 0
            context.draw(resolved, at: CGPoint(x: x, y: Self.baseline - baselineOffset), anchor: .topLeading)
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }
}
