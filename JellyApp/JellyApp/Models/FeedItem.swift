//
//  FeedItem.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import Foundation

struct FeedItem: Identifiable {
    let id: String
    let videoURL: URL
    let thumbnailURL: URL
    let username: String
    let caption: String
    let likes: Int
    let comments: Int
    let timestamp: Date
}
