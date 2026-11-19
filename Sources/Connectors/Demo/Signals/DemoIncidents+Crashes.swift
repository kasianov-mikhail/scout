//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DemoIncidents {
    static let crashSignatures: [(name: String, reason: String, frames: [String])] = [
        (
            "NSRangeException", "*** -[__NSArrayM objectAtIndexedSubscript:]: index 5 beyond bounds [0 .. 3]",
            DemoIncidents.stackTrace(frames: [
                ("CoreFoundation", "__exceptionPreprocess + 164"),
                ("libobjc.A.dylib", "objc_exception_throw + 88"),
                ("CoreFoundation", "-[__NSArrayM objectAtIndexedSubscript:] + 1196"),
                ("MyApp", "FeedViewController.collectionView(_:cellForItemAt:) + 312"),
                ("UIKitCore", "-[UICollectionView _createPreparedCellForItemAtIndexPath:] + 724"),
                ("UIKitCore", "-[UICollectionView _updateVisibleCellsNow:] + 4036"),
                ("UIKitCore", "-[UICollectionView layoutSubviews] + 288"),
                ("UIKitCore", "-[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 2408"),
                ("QuartzCore", "CA::Layer::layout_if_needed(CA::Transaction*) + 496"),
                ("QuartzCore", "CA::Transaction::commit() + 648"),
                ("UIKitCore", "_UIApplicationFlushCATransaction + 52"),
                ("CoreFoundation", "__CFRunLoopRun + 1980"),
                ("GraphicsServices", "GSEventRunModal + 120"),
                ("UIKitCore", "-[UIApplication _run] + 792"),
                ("MyApp", "main + 96"),
                ("dyld", "start + 6076"),
            ])
        ),
        (
            "EXC_BAD_ACCESS", "KERN_INVALID_ADDRESS at 0x0000000000000010",
            DemoIncidents.stackTrace(frames: [
                ("libobjc.A.dylib", "objc_msgSend + 32"),
                ("MyApp", "ImageCache.image(for:) + 148"),
                ("MyApp", "ProductCell.configure(with:) + 404"),
                ("MyApp", "CatalogDataSource.cell(for:at:) + 220"),
                ("UIKitCore", "-[UITableView _createPreparedCellForGlobalRow:withIndexPath:] + 804"),
                ("UIKitCore", "-[UITableView _updateVisibleCellsNow:] + 1488"),
                ("UIKitCore", "-[UITableView layoutSubviews] + 148"),
                ("QuartzCore", "CA::Layer::layout_if_needed(CA::Transaction*) + 496"),
                ("QuartzCore", "CA::Transaction::commit() + 648"),
                ("CoreFoundation", "__CFRunLoopRun + 1980"),
                ("GraphicsServices", "GSEventRunModal + 120"),
                ("UIKitCore", "-[UIApplication _run] + 792"),
                ("MyApp", "main + 96"),
                ("dyld", "start + 6076"),
            ])
        ),
        (
            "EXC_BREAKPOINT", "Fatal error: Unexpectedly found nil while unwrapping an Optional value",
            DemoIncidents.stackTrace(frames: [
                ("libswiftCore.dylib", "_assertionFailure(_:_:file:line:flags:) + 176"),
                ("MyApp", "CheckoutViewModel.confirm() + 1240"),
                ("MyApp", "closure #1 in CheckoutView.body.getter + 92"),
                ("SwiftUICore", "ButtonAction.callAsFunction() + 64"),
                ("SwiftUI", "PrimitiveButtonGestureCallbacks.dispatch(phase:) + 128"),
                ("SwiftUICore", "GestureNode.dispatch(events:) + 512"),
                ("UIKitCore", "-[UIGestureRecognizer _updateGestureForActiveEvents] + 304"),
                ("UIKitCore", "-[UIApplication sendEvent:] + 2800"),
                ("CoreFoundation", "__CFRunLoopDoSource0 + 172"),
                ("CoreFoundation", "__CFRunLoopRun + 836"),
                ("GraphicsServices", "GSEventRunModal + 120"),
                ("SwiftUI", "UIApplicationMain + 340"),
                ("MyApp", "main + 96"),
                ("dyld", "start + 6076"),
            ])
        ),
        (
            "NSInvalidArgumentException", "-[NSNull length]: unrecognized selector sent to instance 0x1f2c4e0a8",
            DemoIncidents.stackTrace(frames: [
                ("CoreFoundation", "__exceptionPreprocess + 164"),
                ("libobjc.A.dylib", "objc_exception_throw + 88"),
                ("CoreFoundation", "-[NSObject(NSObject) doesNotRecognizeSelector:] + 364"),
                ("CoreFoundation", "___forwarding___ + 1560"),
                ("CoreFoundation", "_CF_forwarding_prep_0 + 96"),
                ("MyApp", "ProfileStore.decode(_:) + 268"),
                ("MyApp", "closure #1 in ProfileStore.refresh() + 412"),
                ("libswift_Concurrency.dylib", "completeTaskWithClosure(swift::AsyncContext*, swift::SwiftError*) + 1"),
                ("libdispatch.dylib", "_dispatch_main_queue_drain + 1092"),
                ("CoreFoundation", "__CFRunLoopRun + 1628"),
                ("GraphicsServices", "GSEventRunModal + 120"),
                ("UIKitCore", "-[UIApplication _run] + 792"),
                ("MyApp", "main + 96"),
                ("dyld", "start + 6076"),
            ])
        ),
    ]

    private static func stackTrace(frames: [(module: String, symbol: String)]) -> [String] {
        let bases = [
            "CoreFoundation": 0x1_8044_0000, "libobjc.A.dylib": 0x1_8007_0000, "UIKitCore": 0x1_8520_0000,
            "QuartzCore": 0x1_8890_0000, "GraphicsServices": 0x1_A3D0_0000, "dyld": 0x1_A6F1_0000,
            "libswiftCore.dylib": 0x1_92E0_0000, "SwiftUI": 0x1_8A40_0000, "SwiftUICore": 0x1_89F0_0000,
            "libdispatch.dylib": 0x1_8017_0000, "libswift_Concurrency.dylib": 0x1_9A1B_0000,
        ]
        return frames.enumerated().map { index, frame in
            let base = bases[frame.module] ?? 0x1_0042_0000
            let hash = frame.symbol.unicodeScalars.reduce(5381) { ($0 &* 33 &+ Int($1.value)) & 0xFFFF_FFFF }
            let address = base + hash % 0xF_FFFF
            let module = frame.module.padding(toLength: max(19, frame.module.count + 1), withPad: " ", startingAt: 0)
            let number = String(index).padding(toLength: 4, withPad: " ", startingAt: 0)
            return "\(number)\(module)0x\(String(format: "%016llx", address)) \(frame.symbol)"
        }
    }
}
