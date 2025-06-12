//
//  VideoItem.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import Foundation
import SwiftUI

struct VideoItem: Identifiable {
    let id: String
    let url: URL
    let name: String
    let thumbnail: UIImage?
}
