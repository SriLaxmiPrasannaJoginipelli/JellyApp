//
//  FullScreenVideoView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

//import SwiftUI
//import AVKit
//
//struct FullScreenVideoView: View {
//    let videoURL: URL
//    @State private var player: AVPlayer?
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        ZStack {
//            if let player = player {
//                VideoPlayer(player: player)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear {
//                        player.play()
//                    }
//                    .onDisappear {
//                        player.pause()
//                    }
//            } else {
//                Color.black.edgesIgnoringSafeArea(.all)
//                ProgressView()
//            }
//            
//            VStack {
//                HStack {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "chevron.down")
//                            .font(.title)
//                            .padding()
//                            .background(Circle().fill(Color.black.opacity(0.5)))
//                    }
//                    .padding()
//                    
//                    Spacer()
//                }
//                
//                Spacer()
//            }
//            .foregroundColor(.white)
//        }
//        .onAppear {
//            player = AVPlayer(url: videoURL)
//        }
//        .onDisappear {
//            player?.pause()
//            player = nil
//        }
//    }
//}
//
//
