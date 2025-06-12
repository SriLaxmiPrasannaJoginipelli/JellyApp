//
//  PreviewView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import SwiftUI
import AVKit

struct PreviewView: View {
    let frontCameraURL: URL
    let backCameraURL: URL
    
    var body: some View {
        VStack {
            Text("Recording Complete")
                .font(.title)
                .padding()
            
            HStack {
                VideoPlayer(player: AVPlayer(url: frontCameraURL))
                    .frame(height: 200)
                VideoPlayer(player: AVPlayer(url: backCameraURL))
                    .frame(height: 200)
            }
            
            Spacer()
        }
    }
}


