//
//  RecordedVideo.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI
import AVFoundation

struct RecordedVideo: Identifiable, Codable {
    let id: String
    let url: URL
    let date: Date
    var thumbnail: UIImage? {
        get {
            try? VideoStorageService.loadThumbnail(for: id)
        }
        set {
            if let newValue = newValue {
                try? VideoStorageService.saveThumbnail(newValue, for: id)
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, url, date
    }
}
