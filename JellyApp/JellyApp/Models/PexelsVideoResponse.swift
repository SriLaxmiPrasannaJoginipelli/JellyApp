//
//  PexelsVideoResponse.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import Foundation

struct PexelsVideoResponse: Codable {
    let page: Int
    let per_page: Int
    let total_results: Int
    let videos: [PexelsVideo]
}

struct PexelsVideo: Codable, Identifiable {
    let id: Int
    let url: String
    let image: String
    let video_files: [VideoFile]

    struct VideoFile: Codable {
        let id: Int
        let quality: String
        let file_type: String
        let link: String
    }
}

