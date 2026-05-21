//
//  InlineAdView.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusKit

/**
 A SwiftUI view that displays an inline ad (banner, native, or dynamic unit).

 The ad is presented inline in your layout and refreshes itself internally according to the
 ad's configured refresh interval. Use a `.frame` modifier to control the ad's size — either
 with explicit dimensions or just a height to let the ad stretch to fill the container's width.

 ## Example
```swift
 InlineAdView(ad: Nimbus.bannerAd(position: "banner", size: .banner, refreshInterval: 30))
     .frame(width: 320, height: 50)
```
 */
public struct InlineAdView: View {
    @State private var viewModel: AdViewModel<InlineAd>
    
    /**
     Creates an inline ad view.

     - Parameter ad: The inline ad to display. Construct using `Nimbus.bannerAd(position:size:refreshInterval:)`,
                     `Nimbus.dynamicUnit(position:refreshInterval:)`, or `Nimbus.inlineAd(position:)`.
     */
    public init(ad: InlineAd) {
        self._viewModel = State(wrappedValue: AdViewModel(ad: ad))
    }
    
    public var body: some View {
        UIViewHost { view in
            do {
                try await viewModel.ad.show(in: view)
            } catch let error as NimbusError {
                viewModel.onError?(error)
            } catch {
                viewModel.onError?(.swiftui(stage: .render, detail: error.localizedDescription))
            }
        }
    }
    
    /**
     Registers a handler called for each ad event.

     - Parameter action: Closure invoked with each `AdEvent` fired by the ad.
     - Returns: A modified view with the event handler attached.

     ## Example
     ```swift
     InlineAdView(ad: ad).onEvent { event in print(event) }
     ```
     */
    public func onEvent(perform action: @escaping (AdEvent) -> Void) -> Self {
        then({ $0.viewModel.onEvent = action })
    }
    
    /**
     Registers a handler called when the ad encounters an error.

     - Parameter action: Closure invoked with the `NimbusError`.
     - Returns: A modified view with the error handler attached.

     ## Example
     ```swift
     InlineAdView(ad: ad).onError { error in print(error) }
     ```
     */
    public func onError(perform action: @escaping (NimbusError) -> Void) -> Self {
        then({ $0.viewModel.onError = action })
    }
}
