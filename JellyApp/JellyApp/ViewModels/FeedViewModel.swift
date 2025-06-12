//
//  FeedViewModel.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import Foundation
import Combine

class FeedViewModel: ObservableObject {
    @Published var videos: [PexelsVideo] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    private let apiKey = Secrets.pexelsAPIKey
    private let urlString = "https://api.pexels.com/videos/popular?per_page=10"

    func loadVideos() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: PexelsVideoResponse.self, decoder: JSONDecoder())
            .map { $0.videos }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] videos in
                self?.videos = videos
            }
            .store(in: &cancellables)
    }
}
