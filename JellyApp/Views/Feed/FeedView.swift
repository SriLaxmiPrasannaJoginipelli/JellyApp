//
//  FeedView.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI
import AVKit




struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])) {
                        viewModel.loadVideos()
                    }
                }
                else if viewModel.videos.isEmpty {
                    ProgressView("Loading...")
                        .foregroundColor(.white)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 0) {
                            // Spacer at top for bounce room
                            Color.clear
                                .frame(height: 50)

                            ForEach(viewModel.videos) { video in
                                TikTokVideoCardView(video: video)
                                    .frame(height: UIScreen.main.bounds.height)
                            }

                            
                            Color.clear
                                .frame(height: 100)
                        }
                    }
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("Feed", displayMode: .inline)
            .onAppear {
                viewModel.loadVideos()
            }
        }
    }
}


#Preview {
    FeedView()
}
