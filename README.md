# NimbusSwiftUI

SwiftUI integration for the [Nimbus SDK](https://docs.adsbynimbus.com/docs/sdk/ios). Provides idiomatic SwiftUI views and view models for inline and fullscreen ads.

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Inline ads](#inline-ads)
  - [Fullscreen ads](#fullscreen-ads)
  - [Preloading fullscreen ads](#preloading-fullscreen-ads)
  - [Providing an explicit presentation context](#providing-an-explicit-presentation-context)
- [Sample app](#sample-app)
- [Documentation](#documentation)

## Requirements

- iOS 17.0+
- Xcode 26+

## Installation

### Swift Package Manager

**Via Xcode:**

1. **File → Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/adsbynimbus/nimbus-ios-swiftui`
3. Set the rule to **Up to Next Major Version** with `1.0.0` as the minimum.
4. Select the **NimbusSwiftUI** library when prompted.

**Via `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-swiftui", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusSwiftUI", package: "nimbus-ios-swiftui")
```

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'NimbusSwiftUI'
```

Then run:

```sh
pod install
```

## Usage

> **Important**
> Set event and error handlers via the `.onEvent`/`.onError` modifiers on `InlineAdView`, `FullscreenAdView`, or `FullscreenAdViewModel` — not directly on the underlying `Ad`. The SwiftUI wrappers attach their own listeners to the ad internally and forward events to your handlers. Setting handlers on the ad directly will be overridden.

### Inline ads

Use `InlineAdView` to display banner, native, or dynamic-size ad units inline in your layout. The ad is constructed with one of:

- `Nimbus.bannerAd(position:size:refreshInterval:)`
- `Nimbus.dynamicUnit(position:)`
- `Nimbus.inlineAd(position:)`

```swift
InlineAdView(ad: Nimbus.bannerAd(position: "banner", size: .banner, refreshInterval: 30))
    .onEvent { debugPrint("Banner Event: \($0)") }
    .onError { debugPrint("Banner Error: \($0)") }
    .frame(width: 320, height: 50)
```

#### Flexible sizing

If you specify only a height, the ad will stretch to fill the container's width while preserving its aspect ratio:

```swift
InlineAdView(ad: Nimbus.bannerAd(position: "banner", size: .banner, refreshInterval: 30))
    .frame(height: 70)
```

This is useful for feed layouts where ads should adapt to the row width.

### Fullscreen ads

Use `FullscreenAdView` for interstitial and rewarded ads. The ad is constructed with one of:

- `Nimbus.interstitialAd(position:)`
- `Nimbus.rewardedAd(position:)`
- `Nimbus.fullscreenAd(position:)`

Adding `FullscreenAdView` to your view body automatically loads and presents the ad:

```swift
FullscreenAdView(ad: Nimbus.interstitialAd(position: "interstitial"))
    .onEvent { debugPrint("Interstitial Event: \($0)") }
    .onError { debugPrint("Interstitial Error: \($0)") }
```

### Preloading fullscreen ads

For better UX, preload an ad before showing it so it plays instantly when triggered. Use `FullscreenAdViewModel` to manage the lifecycle separately from presentation:

```swift
struct InterstitialExample: View {
    @State private var viewModel: FullscreenAdViewModel
    
    init(ad: InterstitialAd) {
        self._viewModel = State(wrappedValue: FullscreenAdViewModel(ad: ad))
        self.viewModel.onEvent = { debugPrint("Event: \($0)") }
        self.viewModel.onError = { debugPrint("Error: \($0)") }
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

Usage:

```swift
InterstitialExample(ad: Nimbus.interstitialAd(position: "interstitial"))
```

`viewModel.isReady` is an observable property that flips to `true` once the ad finishes loading, automatically enabling the Show button.

### Providing an explicit presentation context

By default, `FullscreenAdViewModel.show()` walks the app's window hierarchy to find a root view controller to present from. This works for the vast majority of apps.

For more complex hosting scenarios — multi-window iPad apps, SwiftUI embedded in a UIKit container, or cases where the auto-detected view controller isn't the right one — mount `FullscreenAdView` in your view hierarchy to provide an explicit presentation context:

```swift
struct MyScreen: View {
    @State private var viewModel = FullscreenAdViewModel(
        ad: Nimbus.interstitialAd(position: "interstitial")
    )
    @State private var showing = false
    
    var body: some View {
        Button("Show") { showing = true }
            .disabled(!viewModel.isReady)
        
        if showing {
            FullscreenAdView(viewModel: viewModel)
        }
    }
}
```

When `FullscreenAdView` is mounted, the ad presents from its hosted view controller, which is parented under your SwiftUI hierarchy and inherits the correct window, scene, and presentation context.

## Sample app

A complete sample app demonstrating every integration pattern lives in the [`Examples/`](./Examples) directory. Clone the repository and open `Examples/SwiftUISample/SwiftUISample.xcodeproj` to explore working code for inline ads, fullscreen ads, preloading, and ads in scrolling feeds.

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs/sdk/ios) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.
