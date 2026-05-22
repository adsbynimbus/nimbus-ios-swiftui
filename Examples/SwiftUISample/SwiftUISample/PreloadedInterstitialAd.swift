//
//  PreloadedRewardedAd.swift
//  SwiftUISample
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusSwiftUI
import NimbusKit

struct PreloadedInterstitialAd: View {
    @State private var viewModel: FullscreenAdViewModel
    
    init(ad: InterstitialAd) {
        self._viewModel = State(wrappedValue: FullscreenAdViewModel(ad: ad, closeButtonDelay: 7))
        self.viewModel.onEvent = { debugPrint("Event: \($0)") }
        self.viewModel.onError = { debugPrint("Error: \($0)") }
    }
    
    var body: some View {
        VStack {
            Button("Preload") {
                Task {
                    do { try await viewModel.load() }
                    catch { debugPrint("Load failed: \(error.localizedDescription)") }
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isReady)
            
            Button("Show") {
                Task {
                    do { try await viewModel.show() }
                    catch { debugPrint("Show failed: \(error.localizedDescription)") }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isReady)
        }
    }
}

#Preview {
    PreloadedInterstitialAd(ad: Nimbus.interstitialAd(position: "rewarded"))
}
