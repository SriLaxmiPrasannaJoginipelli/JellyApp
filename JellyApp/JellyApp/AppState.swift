//
//  AppState.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var recordedVideos: [RecordedVideo] = []

    func addVideos(_ videos: [RecordedVideo]) {
        recordedVideos.append(contentsOf: videos)
    }

    
    private func loadVideos() {
        do {
            recordedVideos = try VideoStorageService.loadAllVideos()
        } catch {
            print("Error loading videos: \(error.localizedDescription)")
        }
    }
    
    private func saveVideos() {
        // In a real app, we might save metadata to UserDefaults or CoreData
        // The actual video files are already saved by VideoStorageService
    }
}
