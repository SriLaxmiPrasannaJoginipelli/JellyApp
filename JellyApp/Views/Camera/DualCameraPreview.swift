//
//  CameraPreview.swift
//  JellyApp
//
//  Created by Srilu Rao on 6/3/25.
//

import SwiftUI
import AVFoundation

struct DualCameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: DualCameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let frontLayer = cameraManager.previewLayerFront, let backLayer = cameraManager.previewLayerBack {
            frontLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2)
            backLayer.frame = CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: view.bounds.height / 2)
            
            view.layer.addSublayer(frontLayer)
            view.layer.addSublayer(backLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let frontLayer = cameraManager.previewLayerFront, let backLayer = cameraManager.previewLayerBack {
            frontLayer.frame = CGRect(x: 0, y: 0, width: uiView.bounds.width, height: uiView.bounds.height / 2)
            backLayer.frame = CGRect(x: 0, y: uiView.bounds.height / 2, width: uiView.bounds.width, height: uiView.bounds.height / 2)
        }
    }
}
