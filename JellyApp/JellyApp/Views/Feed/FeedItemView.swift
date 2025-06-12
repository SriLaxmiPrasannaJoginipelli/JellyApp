//
//  FeedItemView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI
import AVKit

struct FeedItemView: View {
    let item: FeedItem
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        isPlaying = true
                    }
                    .onDisappear {
                        player.pause()
                        isPlaying = false
                    }
            } else {
                AsyncImage(url: item.thumbnailURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .aspectRatio(9/16, contentMode: .fit)
            }
            
            VStack {
                Spacer()
                FeedItemOverlay(item: item)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: item.videoURL)
        player?.isMuted = true
        player?.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                             object: player?.currentItem,
                                             queue: .main) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

struct FeedItemOverlay: View {
    let item: FeedItem
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text("@\(item.username)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(item.caption)
                    .font(.subheadline)
                
                HStack(spacing: 16) {
                    Label("\(item.likes)", systemImage: "heart")
                    Label("\(item.comments)", systemImage: "bubble.right")
                }
                .font(.caption)
            }
            
            Spacer()
            
            VStack(spacing: 24) {
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.title)
                        Text("\(item.likes)")
                            .font(.caption)
                    }
                }
                
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.title)
                        Text("\(item.comments)")
                            .font(.caption)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.title)
                }
                
                Button(action: {}) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.title)
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            ))
    }
}



