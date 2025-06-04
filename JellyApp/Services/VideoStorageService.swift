//
//  VideoStorageService.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import Foundation
import UIKit


class VideoStorageService {
    
    // MARK: - Save Thumbnail
    static func saveThumbnail(_ image: UIImage, for id: String) throws {
        let data = image.jpegData(compressionQuality: 0.8)
        let url = thumbnailURL(for: id)
        try data?.write(to: url)
    }

    // MARK: - Load Thumbnail
    static func loadThumbnail(for id: String) throws -> UIImage? {
        let url = thumbnailURL(for: id)
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }

    // MARK: - Thumbnail Path
    static func thumbnailURL(for id: String) -> URL {
        let documents = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("\(id)_thumb.jpg")
    }

    // MARK: - Video Storage Path
    static func videoDirectory() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RecordedVideos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func videoURL(for id: String) -> URL {
        videoDirectory().appendingPathComponent("\(id).mov")
    }

    // MARK: - Save Video
    static func saveVideo(from sourceURL: URL, with id: String) throws -> URL {
        let destinationURL = videoURL(for: id)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    // MARK: - Load All Videos
    static func loadAllVideos() -> [RecordedVideo] {
        let videoFiles = try? FileManager.default.contentsOfDirectory(at: videoDirectory(), includingPropertiesForKeys: nil)

        return videoFiles?.compactMap { url in
            guard url.pathExtension == "mov" else { return nil }
            let id = url.deletingPathExtension().lastPathComponent
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            let date = attributes?[.creationDate] as? Date ?? Date()

            var video = RecordedVideo(id: id, url: url, date: date)
            video.thumbnail = try? loadThumbnail(for: id)
            return video
        } ?? []
    }

    // MARK: - Delete Video
    static func deleteVideo(_ video: RecordedVideo) throws {
        try FileManager.default.removeItem(at: video.url)
        try? FileManager.default.removeItem(at: thumbnailURL(for: video.id))
    }
}

