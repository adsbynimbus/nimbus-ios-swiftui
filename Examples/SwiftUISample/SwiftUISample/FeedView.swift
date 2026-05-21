//
//  FeedView.swift
//  SwiftUISample
//  Created on 5/19/26
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import SwiftUI
import NimbusSwiftUI
import NimbusKit

// MARK: - Data Model

struct FeedPost: Identifiable, Hashable {
    let id: Int
    let title: String
    let body: String
    let imageURL: URL
    
    static func mock(id: Int) -> FeedPost {
        FeedPost(
            id: id,
            title: "Post #\(id)",
            body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore.",
            imageURL: URL(string: "https://picsum.photos/seed/\(id)/600/300")!
        )
    }
}

// MARK: - Ad Frame

/// Frame for an ad in the feed. Use `nil` width for flexible width (e.g., banners that fill the row).
struct AdFrame {
    let width: CGFloat?
    let height: CGFloat
    
    static func fixed(width: CGFloat, height: CGFloat) -> AdFrame {
        AdFrame(width: width, height: height)
    }
    
    static func flexible(height: CGFloat) -> AdFrame {
        AdFrame(width: nil, height: height)
    }
}

// MARK: - Feed Item (post or ad)

enum FeedItem: Identifiable, Hashable {
    case post(FeedPost)
    case ad(id: String)
    
    var id: String {
        switch self {
        case .post(let post): return "post-\(post.id)"
        case .ad(let id): return "ad-\(id)"
        }
    }
}

// MARK: - Feed View Model

@Observable
@MainActor
final class FeedViewModel {
    private(set) var items: [FeedItem] = []
    private(set) var isLoading = false
    
    private let postCount: Int
    private let adFrequency: Int
    
    init(postCount: Int = 20, adFrequency: Int = 5) {
        self.postCount = postCount
        self.adFrequency = adFrequency
    }
    
    func loadInitialFeed() async {
        guard items.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        let posts = (1...postCount).map(FeedPost.mock)
        items = interleaveAds(into: posts)
    }
    
    private func interleaveAds(into posts: [FeedPost]) -> [FeedItem] {
        var result: [FeedItem] = []
        for (index, post) in posts.enumerated() {
            result.append(.post(post))
            if (index + 1) % adFrequency == 0 {
                result.append(.ad(id: "ad-\(index / adFrequency)"))
            }
        }
        return result
    }
}

// MARK: - Row Views

struct PostRow: View {
    let post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: post.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                case .empty:
                    Color.gray.opacity(0.1)
                        .overlay(ProgressView())
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(height: 180)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(post.title)
                .font(.headline)
            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }
}

struct AdRow: View {
    let adID: String
    let frame: AdFrame
    
    @State private var ad: InlineAd
    @State private var auctionID: String?
    
    init(ad: InlineAd, adID: String, frame: AdFrame) {
        self.adID = adID
        self.frame = frame
        self._ad = State(wrappedValue: ad)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Sponsored • slot \(adID) • auction id: \(auctionID ?? "-")")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            InlineAdView(ad: ad)
                .onEvent { event in
                    if event == .loaded, let id = ad.response?.id {
                        auctionID = String(id.prefix(8))
                    }
                }
                .frame(width: frame.width, height: frame.height)
                .frame(maxWidth: .infinity)  // center within row
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Feed Screen

struct FeedView: View {
    private let makeAd: () -> InlineAd
    private let adFrame: AdFrame
    private let postCount: Int
    private let adFrequency: Int
    
    @State private var viewModel: FeedViewModel
    
    init(
        ad: @autoclosure @escaping () -> InlineAd,
        frame: AdFrame,
        postCount: Int = 20,
        adFrequency: Int = 5
    ) {
        self.makeAd = ad
        self.adFrame = frame
        self.postCount = postCount
        self.adFrequency = adFrequency
        self._viewModel = State(wrappedValue: FeedViewModel(
            postCount: postCount,
            adFrequency: adFrequency
        ))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                switch item {
                case .post(let post):
                    PostRow(post: post)
                case .ad(let id):
                    AdRow(ad: makeAd(), adID: id, frame: adFrame)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Feed")
        .task {
            await viewModel.loadInitialFeed()
        }
        .overlay {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(
            ad: Nimbus.bannerAd(
                position: "infeed-banner",
                size: .banner,
                refreshInterval: 30
            ),
            frame: .flexible(height: 60)
        )
    }
}
