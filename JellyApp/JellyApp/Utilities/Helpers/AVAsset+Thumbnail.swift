//
//  AVAsset+Thumbnail.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import AVFoundation
import UIKit

extension AVAsset {
    static func generateThumbnail(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

}
