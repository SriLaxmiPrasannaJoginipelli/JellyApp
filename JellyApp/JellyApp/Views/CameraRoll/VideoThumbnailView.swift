//
//  VideoThumbnailView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI

struct VideoThumbnailView: View {
    let video: VideoItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    if let thumbnail = video.thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipped()
                    } else {
                        Color.gray
                            .frame(width: 150, height: 150)
                    }
                    
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .frame(width: 150, height: 150)
                .cornerRadius(8)
                
                Text(video.name)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}

