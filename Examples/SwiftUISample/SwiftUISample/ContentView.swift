//
//  ContentView.swift
//  SwiftUISample
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusSwiftUI
import NimbusKit

enum Route: Hashable {
    case banner
    case interstitial
    case rewarded
    case feedBanner
    case feedDynamicUnit
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Ad Types") {
                    NavigationLink("Banner Ad", value: Route.banner)
                    NavigationLink("Preloaded Interstitial Ad", value: Route.interstitial)
                    NavigationLink("Rewarded Ad", value: Route.rewarded)
                }
                Section("Feed view") {
                    NavigationLink("Feed with banner ads", value: Route.feedBanner)
                    NavigationLink("Feed with dynamic units", value: Route.feedDynamicUnit)
                }
            }
            .navigationTitle("Sample")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .banner:
                    VStack {
                        InlineAdView(ad: Nimbus.bannerAd(position: "banner", size: .banner, refreshInterval: 30))
                            .frame(width: 320, height: 50)
                        Spacer()
                    }
                    .navigationTitle("Banner Ad")
                case .interstitial:
                    PreloadedInterstitialAd(ad: Nimbus.interstitialAd(position: "preloaded interstitial"))
                        .navigationTitle("Preloaded Interstitial Ad")
                case .rewarded:
                    FullscreenAdView(ad: Nimbus.rewardedAd(position: "rewarded"))
                        .navigationTitle("Rewarded Ad")
                case .feedBanner:
                    FeedView(
                        ad: Nimbus.bannerAd(position: "infeed", size: .banner, refreshInterval: 30),
                        frame: .flexible(height: 70), // flexible width features creative scaling
                        postCount: 40,
                        adFrequency: 5
                    )
                case .feedDynamicUnit:
                    FeedView(
                        ad: Nimbus.dynamicUnit(position: "infeed"),
                        frame: .fixed(width: 320, height: 480),
                        postCount: 30,
                        adFrequency: 10
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
