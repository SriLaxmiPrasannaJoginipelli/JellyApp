//
//  VideoCardView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import SwiftUI
import AVKit


struct TikTokVideoCardView: View {
    let video: PexelsVideo
    @State private var player: AVPlayer?

    private var videoURL: URL? {
        if let sdFile = video.video_files.first(where: { $0.quality == "sd" && $0.file_type == "video/mp4" }),
           let url = URL(string: sdFile.link) {
            return url
        } else if let fallback = video.video_files.first(where: { $0.file_type == "video/mp4" }),
                  let url = URL(string: fallback.link) {
            return url
        } else {
            return nil
        }
    }


    var body: some View {
        ZStack {
            videoBackground
            bottomGradient
            overlayUI
        }
        .onAppear(perform: startPlayer)
        .onDisappear(perform: stopPlayer)
    }

    // MARK: - Subviews

    private var videoBackground: some View {
        Group {
            if let url = videoURL {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 250)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }

    private var overlayUI: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                videoInfo
                Spacer()
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    private var videoInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Video ID: \(video.id)")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(radius: 3)

            if let url = URL(string: video.url) {
                Link("View on Pexels", destination: url)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 20) {
            iconButton(systemName: "heart.fill")
            iconButton(systemName: "message.fill")
            iconButton(systemName: "square.and.arrow.up")
        }
    }

    private func iconButton(systemName: String) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .font(.system(size: 26))
                .shadow(radius: 2)
        }
    }

    // MARK: - Player Management

    private func startPlayer() {
        guard let url = videoURL else { return }
        player = AVPlayer(url: url)
        player?.isMuted = true
        player?.play()
        player?.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }

    private func stopPlayer() {
        player?.pause()
        player = nil
    }
}
