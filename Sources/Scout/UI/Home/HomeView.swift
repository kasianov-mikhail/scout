//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI
import UIKit

public struct HomeView: View {
    let container: CKContainer

    @StateObject private var tint = Tint()
    @StateObject private var schema = SchemaLoader()

    public init(container: CKContainer) {
        self.container = container
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch schema.status {
                case .loading:
                    ProgressView()
                case .ready:
                    HomeContent()
                case .schemaError(let error):
                    errorView(error: error)
                }
            }
            .task {
                await schema.verify(in: container)
            }
            .navigationBarTitle("Home")
        }
        .dismissable()
        .iCloudWarning(container: container)
        .tint(tint.value)
        .environmentObject(tint)
        .environment(\.database, container.publicCloudDatabase)
    }

    private func errorView(error: SchemaError) -> some View {
        ErrorView(description: error.styledDescription) {
            Task {
                await schema.verify(in: container)
            }
        }
    }
}

extension SchemaError {
    fileprivate var styledDescription: Text {
        let list = recordTypes.joined(separator: ", ")

        return Text("CloudKit schema is outdated. Missing \(noun): ")
            + Text(list).underline()
            + Text(". Upload the Schema file via CloudKit Console.")
    }
}
#Preview("Schema Error") {
    ErrorView(
        description: SchemaError(recordTypes: ["Crash", "PeriodValue"]).styledDescription,
        retry: {}
    )
}
