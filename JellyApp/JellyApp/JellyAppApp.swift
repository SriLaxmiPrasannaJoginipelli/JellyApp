//
//  JellyAppApp.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/2/25.
//

import SwiftUI


enum AppTab: Int {
    case feed = 0
    case record = 1
    case cameraRoll = 2
}

@main
struct JellyAppApp: App {
    @StateObject private var appState = AppState()
    @State private var selectedTab : AppTab = .feed
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "house.fill")
                    }
                    .tag(AppTab.feed)
                
                CameraTabView()
                    .tabItem {
                        Label("Camera", systemImage: "camera")
                    }
                    .tag(AppTab.record)
                
                CameraRollTabView()
                    .tabItem {
                        Label("Camera Roll", systemImage: "photo.on.rectangle")
                    }
                    .tag(AppTab.cameraRoll)
            }
            .onReceive(NotificationCenter.default.publisher(for: .navigateToTab3)) { _ in
                selectedTab = .cameraRoll
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == .record {
                    NotificationCenter.default.post(name: .startRecordingFromTabSwitch, object: nil)
                }
            }
            .environmentObject(appState)
            .accentColor(.purple)
        }
        
    }
}
