//
//  FullscreenAdViewModel.swift
//  NimbusSwiftUI
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import SwiftUI

/**
 A view model that manages the lifecycle of a fullscreen ad (interstitial or rewarded).

 `FullscreenAdViewModel` wraps a `FullscreenAd` and exposes observable state (`isReady`, `isDestroyed`)
 alongside async methods for loading and presenting the ad. Use it when you need to preload an ad
 ahead of time, observe its lifecycle from SwiftUI, or present the ad from a specific view controller.

 The view model is `@Observable`, so reading `isReady` or `isDestroyed` from a SwiftUI view body
 automatically subscribes the view to changes and triggers re-rendering when state transitions occur.

 ## Example: Preload and show

```swift
 struct InterstitialExample: View {
     @State private var viewModel: FullscreenAdViewModel

     init(ad: InterstitialAd) {
         self._viewModel = State(wrappedValue: FullscreenAdViewModel(ad: ad))
     }

     var body: some View {
         VStack {
             Button("Preload") {
                 Task { try? await viewModel.load() }
             }
             .disabled(viewModel.isReady)

             Button("Show") {
                 Task { try? await viewModel.show() }
             }
             .disabled(!viewModel.isReady)
         }
     }
 }
```
 */
@Observable
@MainActor
public final class FullscreenAdViewModel: AdViewModel<FullscreenAd> {

    /**
     Indicates whether the ad has finished loading and is ready to be presented.

     This property flips to `true` when the ad fires the `.loaded` event. True means
     the ad is ready to be shown.
     */
    public internal(set) var isReady: Bool = false

    /**
     Indicates whether the ad has been destroyed.

     This property flips to `true` when the ad fires the `.destroyed` event and remains `true`
     for the lifetime of the view model. A destroyed ad cannot be shown again — create a new
     `FullscreenAdViewModel` with a fresh ad to present another.
     */
    public internal(set) var isDestroyed: Bool = false

    private let closeButtonDelay: TimeInterval
    private let animated: Bool
    
    /**
     Creates a view model for a fullscreen ad.

     - Parameters:
       - ad: The fullscreen ad to manage. Construct using `Nimbus.interstitialAd(position:)`,
             `Nimbus.rewardedAd(position:)`, or `Nimbus.fullscreenAd(position:)`.
       - closeButtonDelay: Delay in seconds before the close button becomes interactive once the
                           ad is shown. Defaults to `FullscreenAd.defaultCloseButtonDelay`.
       - animated: Whether the presentation transition should be animated. Defaults to `true`.

     ## Example
    ```swift
         @State var viewModel = FullscreenAdViewModel(
             ad: Nimbus.rewardedAd(position: "rewarded")
         )
    ```
     */
    public init(
        ad: FullscreenAd,
        closeButtonDelay: TimeInterval = FullscreenAd.defaultCloseButtonDelay,
        animated: Bool = true
    ) {
        self.closeButtonDelay = closeButtonDelay
        self.animated = animated
        super.init(ad: ad)
    }

    /**
     Loads the ad asynchronously.

     Call this to preload the ad ahead of when it will be shown. Once loading completes
     successfully, `isReady` will be set to `true`. If loading fails, the error is thrown
     or sent via the `onError` callback (if set).

     - Throws: A `NimbusError` if loading fails (e.g., no fill, network error).

     ## Example
    ```swift
    Task { try? await viewModel.load() }
    ```
     */
    public func load() async throws {
        try await ad.load()
    }

    /**
     Presents the ad fullscreen.

     The method returns once the ad has been dismissed (either by the user closing it,
     reward completion, or an error). For best UX, call `load()` first and wait for
     `isReady` to be `true` before calling `show()`.

     - Parameter from: The view controller to present the ad from. If `nil`, the view model
                       will walk the app's window hierarchy to find a suitable presenter.
                       For most apps, `nil` works correctly. Provide an explicit view controller
                       for multi-window iPad apps, SwiftUI embedded in UIKit hosts, or other
                       non-standard hosting scenarios.

     - Throws: A `NimbusError` if the ad cannot be shown (e.g., not loaded, no presenter available).

     ## Example
    ```swift
    Button("Show Ad") {
        Task { try? await viewModel.show() }
    }
    .disabled(!viewModel.isReady)
    ```

     ## Example with explicit presenter
    ```swift
    try await viewModel.show(from: myViewController)
    ```
     */
    public func show(from: UIViewController? = nil) async throws {
        try await ad.show(from: from, closeButtonDelay: closeButtonDelay, animated: animated)
    }

    override func didReceive(event: AdEvent) {
        super.didReceive(event: event)
        if event == .loaded { isReady = true }
        if event == .destroyed { isDestroyed = true }
    }

    override func didReceive(error: NimbusError) {
        super.didReceive(error: error)
    }
}
