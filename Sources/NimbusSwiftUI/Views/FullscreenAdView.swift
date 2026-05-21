//
//  FullscreenAdView.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusKit

/**
 A SwiftUI view that displays a fullscreen ad (interstitial or rewarded).

 When this view appears in the hierarchy, it automatically loads (if needed) and presents
 the ad from its hosted view controller.

 ## Example
```swift
 FullscreenAdView(ad: Nimbus.interstitialAd(position: "interstitial"))
```
 */
public struct FullscreenAdView: View {
    @State private var viewModel: FullscreenAdViewModel
    
    /**
     Creates a fullscreen ad view that loads and presents the ad as soon as it appears.

     - Parameters:
       - ad: The fullscreen ad to present. Construct using `Nimbus.interstitialAd(position:)`,
             `Nimbus.rewardedAd(position:)`, or `Nimbus.fullscreenAd(position:)`.
       - closeButtonDelay: Delay in seconds before the close button becomes interactive.
                           Defaults to `FullscreenAd.defaultCloseButtonDelay`.
       - animated: Whether the presentation transition is animated. Defaults to `true`.
     */
    public init(
        ad: FullscreenAd,
        closeButtonDelay: TimeInterval = FullscreenAd.defaultCloseButtonDelay,
        animated: Bool = true
    ) {
        self._viewModel = State(
            wrappedValue: FullscreenAdViewModel(
                ad: ad,
                closeButtonDelay: closeButtonDelay,
                animated: animated
            )
        )
    }
    
    /**
     Creates a fullscreen ad view backed by an existing view model.

     Use this initializer when you've preloaded the ad ahead of time with a
     ``FullscreenAdViewModel``, or when you need an explicit presentation context — for example
     in multi-window iPad apps or when SwiftUI is embedded in a UIKit host. The `FullscreenAdView`
     presents from its hosted view controller rather than relying on automatic root view controller
     detection.

     - Parameter viewModel: A ``FullscreenAdViewModel`` you've created and configured.

     ## Example
    ```swift
     FullscreenAdView(viewModel: myPreloadedViewModel)
    ```
     */
    public init(viewModel: FullscreenAdViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    /**
     Registers a handler called for each ad event.

     - Parameter action: Closure invoked with each `AdEvent` fired by the ad.
     - Returns: A modified view with the event handler attached.

     ## Example
     ```swift
     FullscreenAdView(ad: ad).onEvent { event in print(event) }
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
     FullscreenAdView(ad: ad).onError { error in print(error) }
     ```
     */
    public func onError(perform action: @escaping (NimbusError) -> Void) -> Self {
        then({ $0.viewModel.onError = action })
    }
    
    public var body: some View {
        UIViewControllerHost { vc in
            do {
                try await viewModel.show(from: vc)
            } catch let error as NimbusError {
                viewModel.onError?(error)
            } catch {
                viewModel.onError?(.swiftui(stage: .render, detail: error.localizedDescription))
            }
        }
    }
}
