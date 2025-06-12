//
//  CameraRollView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI
import AVKit

struct CameraRollTabView: View {
    @StateObject private var storageManager = VideoStorageManager()
    @State private var selectedVideo: VideoItem?
    @State private var isEditing = false
    @State private var selectedToDelete: Set<String> = []

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                    ForEach(storageManager.videos) { video in
                        VideoThumbnailView(video: video) {
                            if isEditing {
                                toggleSelection(for: video)
                            } else {
                                selectedVideo = video
                            }
                        }
                        .overlay(
                            isEditing && selectedToDelete.contains(video.id) ?
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 4) : nil
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Camera Roll")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                            selectedToDelete.removeAll()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Delete") {
                            storageManager.deleteVideos(ids: selectedToDelete)
                            selectedToDelete.removeAll()
                            isEditing = false
                        }
                        .disabled(selectedToDelete.isEmpty)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .sheet(item: $selectedVideo) { video in
                VideoPlayerView(videoURL: video.url)
            }
            .onAppear {
                storageManager.loadVideos()
            }
        }
    }

    private func toggleSelection(for video: VideoItem) {
        if selectedToDelete.contains(video.id) {
            selectedToDelete.remove(video.id)
        } else {
            selectedToDelete.insert(video.id)
        }
    }
}




struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                player.play()
            }
            .onDisappear {
                player.pause()
            }
            .ignoresSafeArea()
    }
}

extension Notification.Name {
    static let navigateToTab3 = Notification.Name("navigateToTab3")
}
