//
//  VideoStorageManager.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import Foundation
import AVKit


class VideoStorageManager: ObservableObject {
    @Published var videos: [VideoItem] = []
    
    func loadVideos() {
        // Load videos from local storage or backend
        // For this example, we'll just look in the temp directory
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let videoURLs = contents.filter { $0.pathExtension == "mov" }
            
            videos = videoURLs.map { url in
                let thumbnail = AVAsset.generateThumbnail(for: url)
                return VideoItem(id: url.lastPathComponent, url: url, name: url.lastPathComponent, thumbnail: thumbnail)
            }
        } catch {
            print("Error loading videos: \(error.localizedDescription)")
        }
    }
    
    
    func saveVideo(frontURL: URL, backURL: URL) {
        // For this example, we'll just reload the videos
        loadVideos()
    }
    
    func deleteVideos(ids: Set<String>) {
        videos.removeAll { video in
            if ids.contains(video.id) {
                do {
                    try FileManager.default.removeItem(at: video.url)
                } catch {
                    print("Failed to delete video: \(error.localizedDescription)")
                }
                return true
            }
            return false
        }
    }

}
