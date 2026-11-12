//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ParamRawView: View {
    let raw: ParamRaw

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "RAW", topPadding: 12, showsSeparator: false)
                .overlay(alignment: .top) {
                    Separator()
                }

            Text(raw.attributed)
                .font(.scoutValue)
                .foregroundStyle(Color.jsonPunctuation)
                .lineSpacing(3.7)
                .textSelection(.enabled)
                .padding(.vertical, .space12)
                .padding(.horizontal, .space12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.jsonBackground, in: RoundedRectangle(cornerRadius: .radiusBlock))
                .padding(.bottom, .space16)
        }
    }
}

#Preview {
    ScrollView {
        ParamRawView(
            raw: ParamRaw(items: [
                ParamProvider.Item(key: "currency", value: "USD"),
                ParamProvider.Item(key: "family_shared", value: "false"),
                ParamProvider.Item(key: "introductory", value: "true"),
                ParamProvider.Item(key: "offer", value: #"{"discount": 0.2, "ends_at": "2026-10-31T23:59:59Z", "id": "FALL26"}"#),
                ParamProvider.Item(key: "price", value: "49.99"),
                ParamProvider.Item(key: "product_id", value: "com.scout.pro.yearly"),
                ParamProvider.Item(key: "promo_codes", value: #"["FALL26", "WELCOME"]"#),
                ParamProvider.Item(key: "purchased_at", value: "2026-10-25T14:52:30Z"),
                ParamProvider.Item(key: "quantity", value: "1"),
                ParamProvider.Item(key: "receipt_url", value: "https://buy.itunes.apple.com/verifyReceipt"),
                ParamProvider.Item(key: "transaction_id", value: "1B2F4A89-0C3D-4E5F-A6B7-C8D9E0F1A2B3"),
            ])
        )
        .padding(.horizontal, .gutter)
    }
}
