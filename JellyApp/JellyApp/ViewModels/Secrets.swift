//
//  Secrets.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/4/25.
//

import Foundation

enum Secrets {
    static var pexelsAPIKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["PEXELS_API_KEY"] as? String
        else {
            fatalError("PEXELS_API_KEY not found in Secrets.plist")
        }

        return key
    }
}

